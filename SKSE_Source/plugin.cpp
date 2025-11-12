#include <spdlog/sinks/basic_file_sink.h>
#include <spdlog/spdlog.h>

#include "ActorMapService.h"
#include "PCH.h"
#include "src/PapyrusRelations.h"
#include "src/RelationsFinderAPI.h"

using namespace SKSE;

namespace {
    void SetupLogging() {
        auto logDir = SKSE::log::log_directory();
        if (!logDir) {
            if (auto* console = RE::ConsoleLog::GetSingleton()) {
                console->Print("RelationsFinder: log directory unavailable");
            }
            return;
        }

        std::filesystem::path logPath = *logDir;
        if (!std::filesystem::is_directory(logPath)) {
            logPath = logPath.parent_path();
        }
        logPath /= "RelationsFinder.log";

        std::error_code ec;
        std::filesystem::create_directories(logPath.parent_path(), ec);
        if (ec) {
            if (auto* console = RE::ConsoleLog::GetSingleton()) {
                console->Print("RelationsFinder: failed to create log folder (%s)", ec.message().c_str());
            }
            return;
        }

        auto sink = std::make_shared<spdlog::sinks::basic_file_sink_mt>(logPath.string(), true);
        auto logger = std::make_shared<spdlog::logger>("RelationsFinder", std::move(sink));
        logger->set_level(spdlog::level::debug);
        logger->flush_on(spdlog::level::info);
        logger->set_pattern("[%H:%M:%S] [%l] %v");

        spdlog::set_default_logger(std::move(logger));
        spdlog::info("Logging to {}", logPath.string());
    }

    void PrintToConsole(std::string_view message) {
        SKSE::log::info("{}", message);
        if (auto* console = RE::ConsoleLog::GetSingleton()) {
            console->Print("%s", message.data());
        }
    }

    // Wrapper function that matches the API signature
    std::vector<RE::Actor*> GetNpcRelationshipsWrapper(RE::Actor* npc, const char* associationType,
                                                       const char* hierarchy, std::int32_t minRelationshipRank,
                                                       std::int32_t exactRelationshipRank) {
        return PapyrusRelations::GetNpcRelationships(nullptr, npc, associationType, hierarchy, minRelationshipRank,
                                                     exactRelationshipRank);
    }

    // NEW: Safe callback-based wrapper (no vector crossing DLL boundaries)
    void GetNpcRelationshipsCallbackWrapper(RE::Actor* npc, const char* associationType, const char* hierarchy,
                                            std::int32_t minRelationshipRank, std::int32_t exactRelationshipRank,
                                            RelationsFinderAPI::RelationshipCallbackFn callback,
                                            void* userData) noexcept {
        if (!callback) {
            SKSE::log::warn("GetNpcRelationshipsCallbackWrapper: null callback provided");
            return;
        }

        // Get results locally (in our DLL's heap)
        auto results = PapyrusRelations::GetNpcRelationships(nullptr, npc, associationType, hierarchy,
                                                             minRelationshipRank, exactRelationshipRank);

        // Invoke callback for each result (only pointers cross the DLL boundary)
        for (auto* actor : results) {
            callback(actor, userData);
        }
        // Vector is destroyed here in our DLL's heap - safe!
    }

    // API interface instance - includes both old and new API
    RelationsFinderAPI::APIInterface g_apiInterface{
        RelationsFinderAPI::kAPIVersion,
        GetNpcRelationshipsWrapper,         // DEPRECATED but kept for backwards compatibility
        GetNpcRelationshipsCallbackWrapper  // NEW safe API
    };

    // Store messaging interface for later use
    const SKSE::MessagingInterface* g_messaging = nullptr;
}

// Export function for other plugins to request the API
extern "C" __declspec(dllexport) const RelationsFinderAPI::APIInterface* RequestRelationsFinderAPI() {
    SKSE::log::info("RequestRelationsFinderAPI called by another plugin");
    return &g_apiInterface;
}

SKSEPluginLoad(const LoadInterface* skse) {
    SKSE::Init(skse);

    SetupLogging();
    SKSE::log::info("RelationsFinder plugin loading...");

    // Register Papyrus functions
    if (auto papyrus = SKSE::GetPapyrusInterface()) {
        if (!papyrus->Register(PapyrusRelations::RegisterPapyrus)) {
            SKSE::log::error("Failed to register Papyrus functions");
        } else {
            SKSE::log::info("Papyrus functions registered");
        }
    } else {
        SKSE::log::warn("Papyrus interface unavailable; papyrus functions not registered");
    }

    g_messaging = SKSE::GetMessagingInterface();
    if (g_messaging) {
        if (!g_messaging->RegisterListener([](SKSE::MessagingInterface::Message* message) {
                switch (message->type) {
                    case SKSE::MessagingInterface::kPreLoadGame:
                        SKSE::log::info("PreLoadGame...");
                        break;

                    case SKSE::MessagingInterface::kPostLoadGame:
                    case SKSE::MessagingInterface::kNewGame:
                        SKSE::log::info("New game/Load...");
                        // Build Actor base -> Actor map now that data is loaded
                        ActorMapService::RebuildBaseToActorMap();
                        break;

                    case SKSE::MessagingInterface::kDataLoaded:
                        SKSE::log::info("Data loaded successfully.");
                        if (auto* console = RE::ConsoleLog::GetSingleton()) {
                            console->Print("RelationsFinder: Ready");
                        }
                        // Note: Papyrus functions already registered during plugin load
                        break;

                    case RelationsFinderAPI::kMessageType_Query:
                        // Another plugin is requesting the API - send it back
                        SKSE::log::info("Received API query request, dispatching API interface...");
                        if (g_messaging) {
                            bool result =
                                g_messaging->Dispatch(RelationsFinderAPI::kMessageType_Query, &g_apiInterface,
                                                      sizeof(RelationsFinderAPI::APIInterface), "RelationsFinder");
                            if (result) {
                                SKSE::log::info("RelationsFinder API dispatched successfully");
                            } else {
                                SKSE::log::error("Failed to dispatch RelationsFinder API");
                            }
                        }
                        break;

                    default:
                        break;
                }
            })) {
            SKSE::log::critical("Failed to register messaging listener.");
            return false;
        }

    } else {
        SKSE::log::critical("Messaging interface unavailable.");
        return false;
    }

    return true;
}
