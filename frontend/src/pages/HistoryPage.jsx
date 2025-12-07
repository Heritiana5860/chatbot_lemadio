// import React, { useState, useEffect } from "react";
// import {
//   Search,
//   Calendar,
//   Trash2,
//   Download,
//   FileText,
//   MessageSquare,
//   Clock,
//   Store,
//   Filter,
// } from "lucide-react";
// import { format } from "date-fns";
// import { fr } from "date-fns/locale";
// import ConfirmModal from "../components/ConfirmModal";
// import { useChatContext } from "../contextes/UseChatContext";

// const HistoryPage = () => {
//   const { reloadHistory, salesCenter } = useChatContext();
//   const [searchTerm, setSearchTerm] = useState("");
//   const [filterDate, setFilterDate] = useState("all");
//   const [filterCenter, setFilterCenter] = useState("all");
//   const [selectedConversation, setSelectedConversation] = useState(null);
//   const [history, setHistory] = useState(() => {
//     const stored = localStorage.getItem("chatHistory");
//     if (stored) {
//       const parsed = JSON.parse(stored);
//       return parsed
//         .map((item) => ({ ...item, timestamp: new Date(item.timestamp) }))
//         .reverse();
//     }
//     return [];
//   });
//   const [showConfirmClear, setShowConfirmClear] = useState(false);

//   const loadHistory = () => {
//     const stored = localStorage.getItem("chatHistory");
//     if (stored) {
//       const parsed = JSON.parse(stored);
//       const withDates = parsed.map((item) => ({
//         ...item,
//         timestamp: new Date(item.timestamp),
//       }));
//       setHistory(withDates.reverse());
//     }
//   };

//   useEffect(() => {
//     const timer = setTimeout(() => {
//       loadHistory();
//     }, 0);
//     return () => clearTimeout(timer);
//   }, []);

//   const clearHistory = () => {
//     setShowConfirmClear(true);
//   };

//   const confirmClearHistory = () => {
//     localStorage.removeItem("chatHistory");
//     localStorage.removeItem("feedbacks");
//     setHistory([]);
//     setSelectedConversation(null);
//     reloadHistory();
//   };

//   const deleteConversation = (index) => {
//     const newHistory = history.filter((_, i) => i !== index);
//     setHistory(newHistory);
//     localStorage.setItem("chatHistory", JSON.stringify(newHistory.reverse()));
//     if (selectedConversation === index) {
//       setSelectedConversation(null);
//     }
//     reloadHistory();
//   };

//   const exportHistory = () => {
//     const dataStr = JSON.stringify(history, null, 2);
//     const dataBlob = new Blob([dataStr], { type: "application/json" });
//     const url = URL.createObjectURL(dataBlob);
//     const link = document.createElement("a");
//     link.href = url;
//     link.download = `historique-lemadio-${format(
//       new Date(),
//       "yyyy-MM-dd"
//     )}.json`;
//     link.click();
//   };

//   // 🆕 Filtrage amélioré avec centre de vente
//   const filteredHistory = history.filter((item) => {
//     const matchesSearch =
//       item.question.toLowerCase().includes(searchTerm.toLowerCase()) ||
//       item.answer.toLowerCase().includes(searchTerm.toLowerCase());

//     // 🆕 Filtre par centre
//     const matchesCenter =
//       filterCenter === "all" ||
//       item.sales_center_id === filterCenter ||
//       (!item.sales_center_id && filterCenter === "no_center");

//     if (filterDate === "all") return matchesSearch && matchesCenter;

//     const now = new Date();
//     const itemDate = item.timestamp;

//     if (filterDate === "today") {
//       return (
//         matchesSearch &&
//         matchesCenter &&
//         itemDate.toDateString() === now.toDateString()
//       );
//     }
//     if (filterDate === "week") {
//       const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
//       return matchesSearch && matchesCenter && itemDate >= weekAgo;
//     }
//     if (filterDate === "month") {
//       const monthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
//       return matchesSearch && matchesCenter && itemDate >= monthAgo;
//     }

//     return matchesSearch && matchesCenter;
//   });

//   // 🆕 Extraire les centres uniques de l'historique
//   const uniqueCenters = [
//     ...new Set(history.map((item) => item.sales_center_id).filter(Boolean)),
//   ];

//   return (
//     <div className="flex h-full bg-gradient-to-br from-gray-50 via-white to-gray-50">
//       {/* Liste des conversations */}
//       <div className="w-full lg:w-2/5 border-r border-gray-200 flex flex-col bg-white">
//         {/* Header */}
//         <div className="p-6 border-b border-gray-200 bg-gradient-to-r from-[#4B8A34]/5 to-[#FFCC00]/5">
//           <h1 className="text-2xl font-bold text-gray-900 mb-1">Historique</h1>
//           <p className="text-sm text-gray-600">
//             {filteredHistory.length} conversation
//             {filteredHistory.length > 1 ? "s" : ""}
//           </p>
//           {/* 🆕 Afficher le centre actif */}
//           {salesCenter && (
//             <div className="mt-3 flex items-center gap-2 text-sm text-gray-600">
//               <Store size={14} className="text-[#4B8A34]" />
//               <span className="font-semibold">{salesCenter.name}</span>
//             </div>
//           )}
//         </div>

//         {/* Barre de recherche et filtres */}
//         <div className="p-4 space-y-3 border-b border-gray-200">
//           <div className="relative">
//             <Search
//               size={18}
//               className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
//             />
//             <input
//               type="text"
//               placeholder="Rechercher dans l'historique..."
//               value={searchTerm}
//               onChange={(e) => setSearchTerm(e.target.value)}
//               className="w-full pl-10 pr-4 py-3 border-2 border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#4B8A34] focus:border-transparent"
//             />
//           </div>

//           {/* Filtres par date */}
//           <div className="flex gap-2">
//             {["all", "today", "week", "month"].map((filter) => (
//               <button
//                 key={filter}
//                 onClick={() => setFilterDate(filter)}
//                 className={`flex-1 px-3 py-2 rounded-lg text-xs font-semibold transition-all ${
//                   filterDate === filter
//                     ? "bg-gradient-to-r from-[#4B8A34] to-[#5a9d40] text-white shadow-md"
//                     : "bg-gray-100 text-gray-700 hover:bg-gray-200"
//                 }`}
//               >
//                 {filter === "all" && "Tout"}
//                 {filter === "today" && "Aujourd'hui"}
//                 {filter === "week" && "Semaine"}
//                 {filter === "month" && "Mois"}
//               </button>
//             ))}
//           </div>

//           {/* 🆕 Filtre par centre */}
//           {uniqueCenters.length > 0 && (
//             <div className="pt-2 border-t border-gray-200">
//               <div className="flex items-center gap-2 mb-2">
//                 <Filter size={14} className="text-gray-600" />
//                 <span className="text-xs font-semibold text-gray-600">
//                   FILTRER PAR CENTRE
//                 </span>
//               </div>
//               <select
//                 value={filterCenter}
//                 onChange={(e) => setFilterCenter(e.target.value)}
//                 className="w-full px-3 py-2 border-2 border-gray-200 rounded-lg text-sm font-medium focus:outline-none focus:ring-2 focus:ring-[#4B8A34] focus:border-transparent"
//               >
//                 <option value="all">Tous les centres</option>
//                 {salesCenter && (
//                   <option value={salesCenter.id}>
//                     {salesCenter.name} (actuel)
//                   </option>
//                 )}
//                 {uniqueCenters
//                   .filter((id) => id !== salesCenter?.id)
//                   .map((centerId) => (
//                     <option key={centerId} value={centerId}>
//                       {centerId}
//                     </option>
//                   ))}
//                 <option value="no_center">Sans centre</option>
//               </select>
//             </div>
//           )}
//         </div>

//         {/* Actions */}
//         <div className="p-4 border-b border-gray-200 flex gap-2">
//           <button
//             onClick={exportHistory}
//             disabled={history.length === 0}
//             className="flex-1 flex items-center justify-center gap-2 px-4 py-2.5 bg-gradient-to-r from-[#4B8A34] to-[#5a9d40] text-white rounded-lg hover:from-[#5a9d40] hover:to-[#4B8A34] disabled:opacity-50 disabled:cursor-not-allowed transition-all font-semibold text-sm"
//           >
//             <Download size={16} />
//             Exporter
//           </button>
//           <button
//             onClick={clearHistory}
//             disabled={history.length === 0}
//             className="flex-1 flex items-center justify-center gap-2 px-4 py-2.5 bg-red-500 text-white rounded-lg hover:bg-red-600 disabled:opacity-50 disabled:cursor-not-allowed transition-all font-semibold text-sm"
//           >
//             <Trash2 size={16} />
//             Tout effacer
//           </button>
//         </div>

//         {/* Liste */}
//         <div className="flex-1 overflow-y-auto">
//           {filteredHistory.length === 0 ? (
//             <div className="flex flex-col items-center justify-center h-full text-gray-500 p-8">
//               <MessageSquare size={48} className="text-gray-300 mb-4" />
//               <p className="text-center font-medium">
//                 {searchTerm || filterDate !== "all" || filterCenter !== "all"
//                   ? "Aucune conversation trouvée"
//                   : "Aucun historique pour le moment"}
//               </p>
//               <p className="text-sm text-center mt-2">
//                 {searchTerm || filterDate !== "all" || filterCenter !== "all"
//                   ? "Essayez de modifier vos filtres"
//                   : "Commencez une conversation pour voir l'historique"}
//               </p>
//             </div>
//           ) : (
//             <div className="divide-y divide-gray-100">
//               {filteredHistory.map((item, index) => (
//                 <div
//                   key={index}
//                   onClick={() => setSelectedConversation(index)}
//                   className={`p-4 cursor-pointer transition-all hover:bg-gradient-to-r hover:from-[#4B8A34]/5 hover:to-[#FFCC00]/5 ${
//                     selectedConversation === index
//                       ? "bg-gradient-to-r from-[#4B8A34]/10 to-[#FFCC00]/10 border-l-4 border-[#4B8A34]"
//                       : ""
//                   }`}
//                 >
//                   <div className="flex items-start justify-between mb-2">
//                     <div className="flex items-center gap-2">
//                       <MessageSquare size={16} className="text-[#4B8A34]" />
//                       <span className="text-xs font-semibold text-gray-900">
//                         Question
//                       </span>
//                     </div>
//                     <button
//                       onClick={(e) => {
//                         e.stopPropagation();
//                         deleteConversation(index);
//                       }}
//                       className="p-1 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded transition-colors"
//                     >
//                       <Trash2 size={14} />
//                     </button>
//                   </div>
//                   <p className="text-sm font-medium text-gray-900 mb-2 line-clamp-2">
//                     {item.question}
//                   </p>
//                   <div className="flex items-center gap-3 text-xs text-gray-500 flex-wrap">
//                     <span className="flex items-center gap-1">
//                       <Clock size={12} />
//                       {format(item.timestamp, "dd MMM yyyy • HH:mm", {
//                         locale: fr,
//                       })}
//                     </span>
//                     {item.sources && item.sources.length > 0 && (
//                       <span className="flex items-center gap-1 px-2 py-0.5 bg-[#FFCC00]/20 text-[#4B8A34] rounded-full font-semibold">
//                         <FileText size={12} />
//                         {item.sources.length}
//                       </span>
//                     )}
//                     {/* 🆕 Badge centre */}
//                     {item.sales_center_id && (
//                       <span className="flex items-center gap-1 px-2 py-0.5 bg-[#4B8A34]/10 text-[#4B8A34] rounded-full font-semibold">
//                         <Store size={12} />
//                         {item.sales_center_id === salesCenter?.id
//                           ? "Actuel"
//                           : "Autre"}
//                       </span>
//                     )}
//                   </div>
//                 </div>
//               ))}
//             </div>
//           )}
//         </div>
//       </div>

//       {/* Détail de la conversation */}
//       <div className="hidden lg:block flex-1 bg-white">
//         {selectedConversation !== null ? (
//           <div className="h-full flex flex-col">
//             <div className="p-6 border-b border-gray-200 bg-gradient-to-r from-[#4B8A34]/5 to-[#FFCC00]/5">
//               <div className="flex items-center gap-2 text-sm text-gray-600 mb-2">
//                 <Calendar size={16} className="text-[#4B8A34]" />
//                 {format(
//                   filteredHistory[selectedConversation].timestamp,
//                   "dd MMMM yyyy à HH:mm",
//                   { locale: fr }
//                 )}
//               </div>
//               <h2 className="text-xl font-bold text-gray-900">
//                 Détails de la conversation
//               </h2>
//             </div>

//             <div className="flex-1 overflow-y-auto p-6 space-y-6">
//               {/* Question */}
//               <div className="bg-gradient-to-br from-[#4B8A34] to-[#5a9d40] rounded-2xl p-6 text-white shadow-lg">
//                 <div className="flex items-center gap-2 mb-3">
//                   <div className="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
//                     <MessageSquare size={16} />
//                   </div>
//                   <span className="font-semibold">Question posée</span>
//                 </div>
//                 <p className="text-lg leading-relaxed">
//                   {filteredHistory[selectedConversation].question}
//                 </p>
//               </div>

//               {/* Réponse */}
//               <div className="bg-white border-2 border-gray-100 rounded-2xl p-6 shadow-sm">
//                 <div className="flex items-center gap-2 mb-3">
//                   <div className="w-8 h-8 bg-gradient-to-br from-[#4B8A34]/10 to-[#FFCC00]/10 rounded-lg flex items-center justify-center">
//                     <MessageSquare size={16} className="text-[#4B8A34]" />
//                   </div>
//                   <span className="font-semibold text-gray-900">
//                     Réponse de l'assistant
//                   </span>
//                 </div>
//                 <p className="text-gray-800 leading-relaxed whitespace-pre-wrap">
//                   {filteredHistory[selectedConversation].answer}
//                 </p>

//                 {/* Sources */}
//                 {filteredHistory[selectedConversation].sources &&
//                   filteredHistory[selectedConversation].sources.length > 0 && (
//                     <div className="mt-6 pt-6 border-t border-gray-200">
//                       <div className="flex items-center gap-2 text-sm font-semibold text-gray-700 mb-3">
//                         <FileText size={16} className="text-[#4B8A34]" />
//                         Sources utilisées
//                       </div>
//                       <div className="flex flex-wrap gap-2">
//                         {filteredHistory[selectedConversation].sources.map(
//                           (source, idx) => (
//                             <span
//                               key={idx}
//                               className="px-3 py-1.5 bg-gradient-to-r from-[#4B8A34]/10 to-[#FFCC00]/10 text-[#4B8A34] rounded-lg text-sm font-semibold border border-[#4B8A34]/20"
//                             >
//                               📄 {source}
//                             </span>
//                           )
//                         )}
//                       </div>
//                     </div>
//                   )}
//               </div>
//             </div>
//           </div>
//         ) : (
//           <div className="h-full flex items-center justify-center text-gray-400">
//             <div className="text-center">
//               <FileText size={64} className="mx-auto mb-4 text-gray-300" />
//               <p className="text-lg font-semibold text-gray-600">
//                 Sélectionnez une conversation
//               </p>
//               <p className="text-sm mt-2">
//                 Cliquez sur une conversation pour voir les détails
//               </p>
//             </div>
//           </div>
//         )}
//       </div>
//       <ConfirmModal
//         open={showConfirmClear}
//         title="Supprimer tout l'historique ?"
//         message="Cette action est irréversible. Voulez-vous vraiment tout effacer ?"
//         onClose={() => setShowConfirmClear(false)}
//         onConfirm={confirmClearHistory}
//       />
//     </div>
//   );
// };

// export default HistoryPage;

// src/pages/HistoryPage.jsx - VERSION AVEC API
import React, { useState, useEffect } from "react";
import {
  Search,
  Calendar,
  Trash2,
  Download,
  FileText,
  MessageSquare,
  Clock,
  Store,
  Filter,
  RefreshCw,
  Loader2,
  AlertCircle,
} from "lucide-react";
import { format } from "date-fns";
import { fr } from "date-fns/locale";
import ConfirmModal from "../components/ConfirmModal";
import { useChatContext } from "../contextes/UseChatContext";
import {
  getConversationHistory,
  deleteConversation as apiDeleteConversation,
  clearAllHistory as apiClearAllHistory,
} from "../services/api";

const HistoryPage = () => {
  const { reloadHistory, salesCenter } = useChatContext();

  // États locaux
  const [searchTerm, setSearchTerm] = useState("");
  const [filterDate, setFilterDate] = useState("all");
  const [filterCenter, setFilterCenter] = useState("all");
  const [selectedConversation, setSelectedConversation] = useState(null);
  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Modales de confirmation
  const [showConfirmClear, setShowConfirmClear] = useState(false);
  const [showConfirmDelete, setShowConfirmDelete] = useState(false);
  const [itemToDelete, setItemToDelete] = useState(null);

  // ============================================
  // 📥 CHARGEMENT DE L'HISTORIQUE DEPUIS L'API
  // ============================================
  const loadHistory = async () => {
    try {
      setLoading(true);
      setError(null);

      // Appel API avec filtre de centre
      const centerFilter = filterCenter === "all" ? null : filterCenter;
      const response = await getConversationHistory(centerFilter, 1000, 0);

      if (response.status === "success") {
        // Convertir les timestamps en objets Date
        const withDates = response.data.map((item) => ({
          ...item,
          timestamp: new Date(item.timestamp),
        }));
        setHistory(withDates);

        console.log(
          `✅ ${withDates.length} conversations chargées depuis l'API`
        );
      }
    } catch (err) {
      console.error("❌ Erreur chargement historique:", err);
      setError("Impossible de charger l'historique. Vérifiez votre connexion.");
    } finally {
      setLoading(false);
    }
  };

  // Charger au montage et quand le filtre centre change
  useEffect(() => {
    loadHistory();
  }, [filterCenter]);

  // ============================================
  // 🔄 RAFRAÎCHIR
  // ============================================
  const handleRefresh = () => {
    loadHistory();
    reloadHistory();
  };

  // ============================================
  // 🗑️ SUPPRESSION D'UNE CONVERSATION
  // ============================================
  const deleteConversationHandler = (id) => {
    setItemToDelete(id);
    setShowConfirmDelete(true);
  };

  const confirmDeleteConversation = async () => {
    try {
      console.log(`🗑️ Suppression de la conversation ${itemToDelete}...`);

      await apiDeleteConversation(itemToDelete);

      // Retirer localement
      const newHistory = history.filter((item) => item.id !== itemToDelete);
      setHistory(newHistory);

      // Désélectionner si c'était la conversation active
      if (selectedConversation?.id === itemToDelete) {
        setSelectedConversation(null);
      }

      reloadHistory();
      console.log("✅ Conversation supprimée");
    } catch (err) {
      console.error("❌ Erreur suppression:", err);
      alert(
        "Impossible de supprimer la conversation. Vérifiez vos permissions."
      );
    } finally {
      setShowConfirmDelete(false);
      setItemToDelete(null);
    }
  };

  // ============================================
  // 🗑️ EFFACER TOUT L'HISTORIQUE
  // ============================================
  const clearHistory = () => {
    setShowConfirmClear(true);
  };

  const confirmClearHistory = async () => {
    try {
      console.log("🗑️ Suppression de TOUT l'historique...");

      await apiClearAllHistory();

      // Vider localement
      setHistory([]);
      setSelectedConversation(null);
      reloadHistory();

      console.log("✅ Tout l'historique a été supprimé");
    } catch (err) {
      console.error("❌ Erreur suppression totale:", err);
      alert(
        "Impossible de supprimer l'historique. Vous devez être administrateur."
      );
    } finally {
      setShowConfirmClear(false);
    }
  };

  // ============================================
  // 💾 EXPORTER L'HISTORIQUE
  // ============================================
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
    URL.revokeObjectURL(url);
  };

  // ============================================
  // 🔍 FILTRAGE LOCAL (recherche + date)
  // ============================================
  const filteredHistory = history.filter((item) => {
    // Filtre de recherche
    const matchesSearch =
      item.question.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.answer.toLowerCase().includes(searchTerm.toLowerCase());

    // Filtre de date
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

  // ============================================
  // 📍 EXTRAIRE LES CENTRES UNIQUES
  // ============================================
  const uniqueCenters = [
    ...new Set(history.map((item) => item.sales_center_id).filter(Boolean)),
  ];

  // ============================================
  // 🎨 RENDU
  // ============================================
  return (
    <div className="flex h-full bg-gradient-to-br from-gray-50 via-white to-gray-50">
      {/* ========== LISTE DES CONVERSATIONS ========== */}
      <div className="w-full lg:w-2/5 border-r border-gray-200 flex flex-col bg-white">
        {/* Header */}
        <div className="p-6 border-b border-gray-200 bg-gradient-to-r from-[#4B8A34]/5 to-[#FFCC00]/5">
          <div className="flex items-center justify-between mb-1">
            <h1 className="text-2xl font-bold text-gray-900">Historique</h1>
            <button
              onClick={handleRefresh}
              disabled={loading}
              className="p-2 hover:bg-white/50 rounded-lg transition-colors disabled:opacity-50"
              title="Rafraîchir"
            >
              <RefreshCw
                size={20}
                className={`text-[#4B8A34] ${loading ? "animate-spin" : ""}`}
              />
            </button>
          </div>

          {loading ? (
            <div className="flex items-center gap-2 text-sm text-gray-600">
              <Loader2 size={14} className="animate-spin" />
              <span>Chargement depuis la base de données...</span>
            </div>
          ) : error ? (
            <div className="flex items-center gap-2 text-sm text-red-600">
              <AlertCircle size={14} />
              <span>{error}</span>
            </div>
          ) : (
            <p className="text-sm text-gray-600">
              {filteredHistory.length} conversation
              {filteredHistory.length > 1 ? "s" : ""} • Base de données
            </p>
          )}

          {salesCenter && (
            <div className="mt-3 flex items-center gap-2 text-sm text-gray-600">
              <Store size={14} className="text-[#4B8A34]" />
              <span className="font-semibold">{salesCenter.name}</span>
            </div>
          )}
        </div>

        {/* Barre de recherche et filtres */}
        <div className="p-4 space-y-3 border-b border-gray-200">
          {/* Recherche */}
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

          {/* Filtres par date */}
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

          {/* Filtre par centre */}
          {uniqueCenters.length > 0 && (
            <div className="pt-2 border-t border-gray-200">
              <div className="flex items-center gap-2 mb-2">
                <Filter size={14} className="text-gray-600" />
                <span className="text-xs font-semibold text-gray-600">
                  FILTRER PAR CENTRE
                </span>
              </div>
              <select
                value={filterCenter}
                onChange={(e) => setFilterCenter(e.target.value)}
                className="w-full px-3 py-2 border-2 border-gray-200 rounded-lg text-sm font-medium focus:outline-none focus:ring-2 focus:ring-[#4B8A34] focus:border-transparent"
              >
                <option value="all">Tous les centres</option>
                {salesCenter && (
                  <option value={salesCenter.id}>
                    {salesCenter.name} (actuel)
                  </option>
                )}
                {uniqueCenters
                  .filter((id) => id !== salesCenter?.id)
                  .map((centerId) => (
                    <option key={centerId} value={centerId}>
                      {centerId}
                    </option>
                  ))}
              </select>
            </div>
          )}
        </div>

        {/* Actions */}
        <div className="p-4 border-b border-gray-200 flex gap-2">
          <button
            onClick={exportHistory}
            disabled={history.length === 0 || loading}
            className="flex-1 flex items-center justify-center gap-2 px-4 py-2.5 bg-gradient-to-r from-[#4B8A34] to-[#5a9d40] text-white rounded-lg hover:from-[#5a9d40] hover:to-[#4B8A34] disabled:opacity-50 disabled:cursor-not-allowed transition-all font-semibold text-sm"
          >
            <Download size={16} />
            Exporter
          </button>
          <button
            onClick={clearHistory}
            disabled={history.length === 0 || loading}
            className="flex-1 flex items-center justify-center gap-2 px-4 py-2.5 bg-red-500 text-white rounded-lg hover:bg-red-600 disabled:opacity-50 disabled:cursor-not-allowed transition-all font-semibold text-sm"
          >
            <Trash2 size={16} />
            Tout effacer
          </button>
        </div>

        {/* Liste des conversations */}
        <div className="flex-1 overflow-y-auto">
          {loading ? (
            <div className="flex flex-col items-center justify-center h-full text-gray-500 p-8">
              <Loader2 size={48} className="text-[#4B8A34] animate-spin mb-4" />
              <p className="text-center font-medium">
                Chargement de l'historique...
              </p>
            </div>
          ) : error ? (
            <div className="flex flex-col items-center justify-center h-full text-red-500 p-8">
              <AlertCircle size={48} className="text-red-300 mb-4" />
              <p className="text-center font-medium mb-4">{error}</p>
              <button
                onClick={handleRefresh}
                className="px-4 py-2 bg-[#4B8A34] text-white rounded-lg hover:bg-[#5a9d40] transition-colors"
              >
                Réessayer
              </button>
            </div>
          ) : filteredHistory.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-full text-gray-500 p-8">
              <MessageSquare size={48} className="text-gray-300 mb-4" />
              <p className="text-center font-medium">
                {searchTerm || filterDate !== "all" || filterCenter !== "all"
                  ? "Aucune conversation trouvée"
                  : "Aucun historique pour le moment"}
              </p>
              <p className="text-sm text-center mt-2">
                {searchTerm || filterDate !== "all" || filterCenter !== "all"
                  ? "Essayez de modifier vos filtres"
                  : "Commencez une conversation pour voir l'historique"}
              </p>
            </div>
          ) : (
            <div className="divide-y divide-gray-100">
              {filteredHistory.map((item) => (
                <div
                  key={item.id}
                  onClick={() => setSelectedConversation(item)}
                  className={`p-4 cursor-pointer transition-all hover:bg-gradient-to-r hover:from-[#4B8A34]/5 hover:to-[#FFCC00]/5 ${
                    selectedConversation?.id === item.id
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
                        deleteConversationHandler(item.id);
                      }}
                      className="p-1 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded transition-colors"
                    >
                      <Trash2 size={14} />
                    </button>
                  </div>
                  <p className="text-sm font-medium text-gray-900 mb-2 line-clamp-2">
                    {item.question}
                  </p>
                  <div className="flex items-center gap-3 text-xs text-gray-500 flex-wrap">
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
                    {item.sales_center_id && (
                      <span className="flex items-center gap-1 px-2 py-0.5 bg-[#4B8A34]/10 text-[#4B8A34] rounded-full font-semibold">
                        <Store size={12} />
                        {item.sales_center_id === salesCenter?.id
                          ? "Actuel"
                          : item.sales_center_id}
                      </span>
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* ========== DÉTAIL DE LA CONVERSATION ========== */}
      <div className="hidden lg:block flex-1 bg-white">
        {selectedConversation ? (
          <div className="h-full flex flex-col">
            <div className="p-6 border-b border-gray-200 bg-gradient-to-r from-[#4B8A34]/5 to-[#FFCC00]/5">
              <div className="flex items-center gap-2 text-sm text-gray-600 mb-2">
                <Calendar size={16} className="text-[#4B8A34]" />
                {format(
                  selectedConversation.timestamp,
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
                  {selectedConversation.question}
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
                  {selectedConversation.answer}
                </p>

                {/* Sources */}
                {selectedConversation.sources &&
                  selectedConversation.sources.length > 0 && (
                    <div className="mt-6 pt-6 border-t border-gray-200">
                      <div className="flex items-center gap-2 text-sm font-semibold text-gray-700 mb-3">
                        <FileText size={16} className="text-[#4B8A34]" />
                        Sources utilisées
                      </div>
                      <div className="flex flex-wrap gap-2">
                        {selectedConversation.sources.map((source, idx) => (
                          <span
                            key={idx}
                            className="px-3 py-1.5 bg-gradient-to-r from-[#4B8A34]/10 to-[#FFCC00]/10 text-[#4B8A34] rounded-lg text-sm font-semibold border border-[#4B8A34]/20"
                          >
                            📄 {source}
                          </span>
                        ))}
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

      {/* ========== MODALES DE CONFIRMATION ========== */}
      <ConfirmModal
        open={showConfirmClear}
        title="Supprimer tout l'historique ?"
        message="Cette action supprimera TOUTES les conversations de la base de données de manière irréversible. Êtes-vous sûr ?"
        onClose={() => setShowConfirmClear(false)}
        onConfirm={confirmClearHistory}
      />

      <ConfirmModal
        open={showConfirmDelete}
        title="Supprimer cette conversation ?"
        message="Cette action est irréversible. La conversation sera supprimée de la base de données."
        onClose={() => {
          setShowConfirmDelete(false);
          setItemToDelete(null);
        }}
        onConfirm={confirmDeleteConversation}
      />
    </div>
  );
};

export default HistoryPage;
