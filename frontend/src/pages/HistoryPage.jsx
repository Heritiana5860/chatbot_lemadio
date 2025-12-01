import React, { useState, useEffect } from "react";
import {
  Search,
  Calendar,
  Trash2,
  Download,
  FileText,
  MessageSquare,
  Clock,
} from "lucide-react";
import { format } from "date-fns";
import { fr } from "date-fns/locale";
import { useChatContext } from "../contextes/ChatContext";
import ConfirmModal from "../components/ConfirmModal";

const HistoryPage = () => {
  const { reloadHistory } = useChatContext();

  const [searchTerm, setSearchTerm] = useState("");
  const [filterDate, setFilterDate] = useState("all");
  const [selectedConversation, setSelectedConversation] = useState(null);
  const [history, setHistory] = useState(() => {
    const stored = localStorage.getItem("chatHistory");
    if (stored) {
      const parsed = JSON.parse(stored);
      return parsed
        .map((item) => ({ ...item, timestamp: new Date(item.timestamp) }))
        .reverse();
    }
    return [];
  });
  const [showConfirmClear, setShowConfirmClear] = useState(false);

  const loadHistory = () => {
    const stored = localStorage.getItem("chatHistory");
    if (stored) {
      const parsed = JSON.parse(stored);
      // Convertir les timestamps en objets Date
      const withDates = parsed.map((item) => ({
        ...item,
        timestamp: new Date(item.timestamp),
      }));
      setHistory(withDates.reverse());
    }
  };

  useEffect(() => {
    const timer = setTimeout(() => {
      loadHistory();
    }, 0);
    return () => clearTimeout(timer);
  }, []);

  const clearHistory = () => {
    setShowConfirmClear(true); // Ouvre la modale
  };

  const confirmClearHistory = () => {
    localStorage.removeItem("chatHistory");
    localStorage.removeItem("feedbacks");
    setHistory([]);
    setSelectedConversation(null);
    reloadHistory();
  };

  const deleteConversation = (index) => {
    const newHistory = history.filter((_, i) => i !== index);
    setHistory(newHistory);
    localStorage.setItem("chatHistory", JSON.stringify(newHistory.reverse()));
    if (selectedConversation === index) {
      setSelectedConversation(null);
    }
    reloadHistory(); // ✅ AJOUT : Synchroniser avec ChatPage après suppression
  };

  const exportHistory = () => {
    const dataStr = JSON.stringify(history, null, 2);
    const dataBlob = new Blob([dataStr], { type: "application/json" });
    const url = URL.createObjectURL(dataBlob);
    const link = document.createElement("a");
    link.href = url;
    link.download = `historique-lemadio-${format(
      new Date(),
      "yyyy-MM-dd"
    )}.json`;
    link.click();
  };

  const filteredHistory = history.filter((item) => {
    const matchesSearch =
      item.question.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.answer.toLowerCase().includes(searchTerm.toLowerCase());

    if (filterDate === "all") return matchesSearch;

    const now = new Date();
    const itemDate = item.timestamp;

    if (filterDate === "today") {
      return matchesSearch && itemDate.toDateString() === now.toDateString();
    }
    if (filterDate === "week") {
      const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      return matchesSearch && itemDate >= weekAgo;
    }
    if (filterDate === "month") {
      const monthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
      return matchesSearch && itemDate >= monthAgo;
    }

    return matchesSearch;
  });

  return (
    <div className="flex h-full bg-gradient-to-br from-gray-50 via-white to-gray-50">
      {/* Liste des conversations */}
      <div className="w-full lg:w-2/5 border-r border-gray-200 flex flex-col bg-white">
        {/* Header */}
        <div className="p-6 border-b border-gray-200 bg-gradient-to-r from-[#4B8A34]/5 to-[#FFCC00]/5">
          <h1 className="text-2xl font-bold text-gray-900 mb-1">Historique</h1>
          <p className="text-sm text-gray-600">
            {filteredHistory.length} conversation
            {filteredHistory.length > 1 ? "s" : ""}
          </p>
        </div>

        {/* Barre de recherche et filtres */}
        <div className="p-4 space-y-3 border-b border-gray-200">
          <div className="relative">
            <Search
              size={18}
              className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
            />
            <input
              type="text"
              placeholder="Rechercher dans l'historique..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-3 border-2 border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#4B8A34] focus:border-transparent"
            />
          </div>

          <div className="flex gap-2">
            {["all", "today", "week", "month"].map((filter) => (
              <button
                key={filter}
                onClick={() => setFilterDate(filter)}
                className={`flex-1 px-3 py-2 rounded-lg text-xs font-semibold transition-all ${
                  filterDate === filter
                    ? "bg-gradient-to-r from-[#4B8A34] to-[#5a9d40] text-white shadow-md"
                    : "bg-gray-100 text-gray-700 hover:bg-gray-200"
                }`}
              >
                {filter === "all" && "Tout"}
                {filter === "today" && "Aujourd'hui"}
                {filter === "week" && "Semaine"}
                {filter === "month" && "Mois"}
              </button>
            ))}
          </div>
        </div>

        {/* Actions */}
        <div className="p-4 border-b border-gray-200 flex gap-2">
          <button
            onClick={exportHistory}
            disabled={history.length === 0}
            className="flex-1 flex items-center justify-center gap-2 px-4 py-2.5 bg-gradient-to-r from-[#4B8A34] to-[#5a9d40] text-white rounded-lg hover:from-[#5a9d40] hover:to-[#4B8A34] disabled:opacity-50 disabled:cursor-not-allowed transition-all font-semibold text-sm"
          >
            <Download size={16} />
            Exporter
          </button>
          <button
            onClick={clearHistory}
            disabled={history.length === 0}
            className="flex-1 flex items-center justify-center gap-2 px-4 py-2.5 bg-red-500 text-white rounded-lg hover:bg-red-600 disabled:opacity-50 disabled:cursor-not-allowed transition-all font-semibold text-sm"
          >
            <Trash2 size={16} />
            Tout effacer
          </button>
        </div>

        {/* Liste */}
        <div className="flex-1 overflow-y-auto">
          {filteredHistory.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-full text-gray-500 p-8">
              <MessageSquare size={48} className="text-gray-300 mb-4" />
              <p className="text-center font-medium">
                {searchTerm || filterDate !== "all"
                  ? "Aucune conversation trouvée"
                  : "Aucun historique pour le moment"}
              </p>
              <p className="text-sm text-center mt-2">
                {searchTerm || filterDate !== "all"
                  ? "Essayez de modifier vos filtres"
                  : "Commencez une conversation pour voir l'historique"}
              </p>
            </div>
          ) : (
            <div className="divide-y divide-gray-100">
              {filteredHistory.map((item, index) => (
                <div
                  key={index}
                  onClick={() => setSelectedConversation(index)}
                  className={`p-4 cursor-pointer transition-all hover:bg-gradient-to-r hover:from-[#4B8A34]/5 hover:to-[#FFCC00]/5 ${
                    selectedConversation === index
                      ? "bg-gradient-to-r from-[#4B8A34]/10 to-[#FFCC00]/10 border-l-4 border-[#4B8A34]"
                      : ""
                  }`}
                >
                  <div className="flex items-start justify-between mb-2">
                    <div className="flex items-center gap-2">
                      <MessageSquare size={16} className="text-[#4B8A34]" />
                      <span className="text-xs font-semibold text-gray-900">
                        Question
                      </span>
                    </div>
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        deleteConversation(index);
                      }}
                      className="p-1 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded transition-colors"
                    >
                      <Trash2 size={14} />
                    </button>
                  </div>
                  <p className="text-sm font-medium text-gray-900 mb-2 line-clamp-2">
                    {item.question}
                  </p>
                  <div className="flex items-center gap-3 text-xs text-gray-500">
                    <span className="flex items-center gap-1">
                      <Clock size={12} />
                      {format(item.timestamp, "dd MMM yyyy • HH:mm", {
                        locale: fr,
                      })}
                    </span>
                    {item.sources && item.sources.length > 0 && (
                      <span className="flex items-center gap-1 px-2 py-0.5 bg-[#FFCC00]/20 text-[#4B8A34] rounded-full font-semibold">
                        <FileText size={12} />
                        {item.sources.length}
                      </span>
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Détail de la conversation */}
      <div className="hidden lg:block flex-1 bg-white">
        {selectedConversation !== null ? (
          <div className="h-full flex flex-col">
            <div className="p-6 border-b border-gray-200 bg-gradient-to-r from-[#4B8A34]/5 to-[#FFCC00]/5">
              <div className="flex items-center gap-2 text-sm text-gray-600 mb-2">
                <Calendar size={16} className="text-[#4B8A34]" />
                {format(
                  filteredHistory[selectedConversation].timestamp,
                  "dd MMMM yyyy à HH:mm",
                  { locale: fr }
                )}
              </div>
              <h2 className="text-xl font-bold text-gray-900">
                Détails de la conversation
              </h2>
            </div>

            <div className="flex-1 overflow-y-auto p-6 space-y-6">
              {/* Question */}
              <div className="bg-gradient-to-br from-[#4B8A34] to-[#5a9d40] rounded-2xl p-6 text-white shadow-lg">
                <div className="flex items-center gap-2 mb-3">
                  <div className="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
                    <MessageSquare size={16} />
                  </div>
                  <span className="font-semibold">Question posée</span>
                </div>
                <p className="text-lg leading-relaxed">
                  {filteredHistory[selectedConversation].question}
                </p>
              </div>

              {/* Réponse */}
              <div className="bg-white border-2 border-gray-100 rounded-2xl p-6 shadow-sm">
                <div className="flex items-center gap-2 mb-3">
                  <div className="w-8 h-8 bg-gradient-to-br from-[#4B8A34]/10 to-[#FFCC00]/10 rounded-lg flex items-center justify-center">
                    <MessageSquare size={16} className="text-[#4B8A34]" />
                  </div>
                  <span className="font-semibold text-gray-900">
                    Réponse de l'assistant
                  </span>
                </div>
                <p className="text-gray-800 leading-relaxed whitespace-pre-wrap">
                  {filteredHistory[selectedConversation].answer}
                </p>

                {/* Sources */}
                {filteredHistory[selectedConversation].sources &&
                  filteredHistory[selectedConversation].sources.length > 0 && (
                    <div className="mt-6 pt-6 border-t border-gray-200">
                      <div className="flex items-center gap-2 text-sm font-semibold text-gray-700 mb-3">
                        <FileText size={16} className="text-[#4B8A34]" />
                        Sources utilisées
                      </div>
                      <div className="flex flex-wrap gap-2">
                        {filteredHistory[selectedConversation].sources.map(
                          (source, idx) => (
                            <span
                              key={idx}
                              className="px-3 py-1.5 bg-gradient-to-r from-[#4B8A34]/10 to-[#FFCC00]/10 text-[#4B8A34] rounded-lg text-sm font-semibold border border-[#4B8A34]/20"
                            >
                              📄 {source}
                            </span>
                          )
                        )}
                      </div>
                    </div>
                  )}
              </div>
            </div>
          </div>
        ) : (
          <div className="h-full flex items-center justify-center text-gray-400">
            <div className="text-center">
              <FileText size={64} className="mx-auto mb-4 text-gray-300" />
              <p className="text-lg font-semibold text-gray-600">
                Sélectionnez une conversation
              </p>
              <p className="text-sm mt-2">
                Cliquez sur une conversation pour voir les détails
              </p>
            </div>
          </div>
        )}
      </div>
      <ConfirmModal
        open={showConfirmClear}
        title="Supprimer tout l'historique ?"
        message="Cette action est irréversible. Voulez-vous vraiment tout effacer ?"
        onClose={() => setShowConfirmClear(false)}
        onConfirm={confirmClearHistory}
      />
    </div>
  );
};

export default HistoryPage;
