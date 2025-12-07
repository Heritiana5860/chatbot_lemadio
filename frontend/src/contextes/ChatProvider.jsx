// // src/contexts/ChatContext.jsx
// import { createContext, useContext, useState, useEffect } from "react";

// const ChatContext = createContext(null);

// // Hook personnalisé pour utiliser le context
// export const useChatContext = () => {
//   const context = useContext(ChatContext);
//   if (!context) {
//     throw new Error("useChatContext doit être utilisé dans un ChatProvider");
//   }
//   return context;
// };

// // Message de bienvenue initial
// const welcomeMessage = {
//   id: 1,
//   type: "assistant",
//   content:
//     "Bonjour ! Je suis votre assistant de formation Lemadio. Posez-moi vos questions sur l'utilisation de l'application et je vous guiderai avec plaisir !",
//   timestamp: new Date(),
// };

// // Provider qui va envelopper l'application
// export function ChatProvider({ children }) {
//   // État global pour les messages de la conversation actuelle
//   const [messages, setMessages] = useState([welcomeMessage]);

//   // Charger l'historique complet au démarrage
//   useEffect(() => {
//     const loadHistory = () => {
//       try {
//         const history = JSON.parse(localStorage.getItem("chatHistory") || "[]");

//         if (history.length > 0) {
//           // Convertir l'historique en format messages (avec questions ET réponses)
//           const loadedMessages = [welcomeMessage]; // Garder le message de bienvenue

//           history.forEach((item, index) => {
//             // Message utilisateur (question)
//             loadedMessages.push({
//               id: `user-${index}-${Date.now()}`,
//               type: "user",
//               content: item.question,
//               timestamp: new Date(item.timestamp),
//             });

//             // Message assistant (réponse)
//             loadedMessages.push({
//               id: `assistant-${index}-${Date.now()}`,
//               type: "assistant",
//               content: item.answer,
//               sources: item.sources,
//               timestamp: new Date(item.timestamp),
//               feedback: null,
//             });
//           });

//           setMessages(loadedMessages);
//         }
//       } catch (error) {
//         console.error("Erreur lors du chargement de l'historique:", error);
//       }
//     };

//     loadHistory();
//   }, []);

//   // Fonction pour ajouter un message
//   const addMessage = (message) => {
//     setMessages((prev) => [...prev, message]);
//   };

//   // Fonction pour sauvegarder dans l'historique
//   const saveToHistory = (userMsg, assistantMsg) => {
//     try {
//       const history = JSON.parse(localStorage.getItem("chatHistory") || "[]");
//       history.push({
//         question: userMsg.content,
//         answer: assistantMsg.content,
//         sources: assistantMsg.sources,
//         timestamp: userMsg.timestamp,
//       });
//       localStorage.setItem("chatHistory", JSON.stringify(history.slice(-100)));
//     } catch (error) {
//       console.error("Erreur lors de la sauvegarde:", error);
//     }
//   };

//   // Fonction pour mettre à jour le feedback
//   const updateMessageFeedback = (messageId, feedback) => {
//     setMessages((prev) =>
//       prev.map((msg) => (msg.id === messageId ? { ...msg, feedback } : msg))
//     );

//     try {
//       const feedbacks = JSON.parse(localStorage.getItem("feedbacks") || "[]");
//       feedbacks.push({ messageId, feedback, timestamp: new Date() });
//       localStorage.setItem("feedbacks", JSON.stringify(feedbacks));
//     } catch (error) {
//       console.error("Erreur lors de la sauvegarde du feedback:", error);
//     }
//   };

//   // Fonction pour effacer l'historique
//   const clearHistory = () => {
//     localStorage.removeItem("chatHistory");
//     localStorage.removeItem("feedbacks");
//     setMessages([welcomeMessage]); // Garder seulement le message de bienvenue
//   };

//   // Fonction pour recharger l'historique (utile après suppression)
//   const reloadHistory = () => {
//     try {
//       const history = JSON.parse(localStorage.getItem("chatHistory") || "[]");

//       if (history.length === 0) {
//         setMessages([welcomeMessage]);
//         return;
//       }

//       const loadedMessages = [welcomeMessage];

//       history.forEach((item, index) => {
//         loadedMessages.push({
//           id: `user-${index}-${Date.now()}`,
//           type: "user",
//           content: item.question,
//           timestamp: new Date(item.timestamp),
//         });

//         loadedMessages.push({
//           id: `assistant-${index}-${Date.now()}`,
//           type: "assistant",
//           content: item.answer,
//           sources: item.sources,
//           timestamp: new Date(item.timestamp),
//           feedback: null,
//         });
//       });

//       setMessages(loadedMessages);
//     } catch (error) {
//       console.error("Erreur lors du rechargement:", error);
//     }
//   };

//   const value = {
//     messages,
//     setMessages,
//     addMessage,
//     saveToHistory,
//     updateMessageFeedback,
//     clearHistory,
//     reloadHistory,
//   };

//   return <ChatContext.Provider value={value}>{children}</ChatContext.Provider>;
// }

// src/contexts/ChatContext.jsx
import { useState, useEffect } from "react";
import { syncAnalytics, formatHistoryForSync } from "../services/api";
import { ChatContext, welcomeMessage } from "./UseChatContext";

export function ChatProvider({ children }) {
  const [messages, setMessages] = useState([welcomeMessage]);
  const [salesCenter, setSalesCenter] = useState(null);
  const [isSyncing, setIsSyncing] = useState(false);

  // Charger le centre de vente au démarrage
  useEffect(() => {
    const savedCenter = localStorage.getItem("salesCenter");
    if (savedCenter) {
      setSalesCenter(JSON.parse(savedCenter));
    }
  }, []);

  // Charger l'historique au démarrage
  useEffect(() => {
    const loadHistory = () => {
      try {
        const history = JSON.parse(localStorage.getItem("chatHistory") || "[]");

        if (history.length > 0) {
          const loadedMessages = [welcomeMessage];

          history.forEach((item, index) => {
            loadedMessages.push({
              id: `user-${index}-${Date.now()}`,
              type: "user",
              content: item.question,
              timestamp: new Date(item.timestamp),
            });

            loadedMessages.push({
              id: `assistant-${index}-${Date.now()}`,
              type: "assistant",
              content: item.answer,
              sources: item.sources,
              timestamp: new Date(item.timestamp),
              feedback: null,
            });
          });

          setMessages(loadedMessages);
        }
      } catch (error) {
        console.error("Erreur lors du chargement de l'historique:", error);
      }
    };

    loadHistory();
  }, []);

  // 🆕 Synchronisation automatique périodique (toutes les 5 minutes)
  useEffect(() => {
    const syncInterval = setInterval(() => {
      if (salesCenter) {
        syncHistoryToBackend();
      }
    }, 5 * 60 * 1000); // 5 minutes

    return () => clearInterval(syncInterval);
  }, [salesCenter]);

  const addMessage = (message) => {
    setMessages((prev) => [...prev, message]);
  };

  // 🆕 Sauvegarder dans l'historique AVEC centre de vente
  const saveToHistory = (userMsg, assistantMsg) => {
    try {
      const history = JSON.parse(localStorage.getItem("chatHistory") || "[]");

      const newEntry = {
        question: userMsg.content,
        answer: assistantMsg.content,
        sources: assistantMsg.sources || [],
        timestamp: userMsg.timestamp,
        sales_center_id: salesCenter?.id || null, // 🆕
      };

      history.push(newEntry);
      localStorage.setItem("chatHistory", JSON.stringify(history.slice(-100)));

      // 🆕 Sync immédiatement si centre de vente défini
      if (salesCenter) {
        syncHistoryToBackend();
      }
    } catch (error) {
      console.error("Erreur lors de la sauvegarde:", error);
    }
  };

  // 🆕 Synchroniser l'historique vers PostgreSQL
  const syncHistoryToBackend = async () => {
    if (!salesCenter) {
      console.warn("Centre de vente non défini, synchronisation ignorée");
      return;
    }

    if (isSyncing) {
      console.log("Synchronisation déjà en cours...");
      return;
    }

    try {
      setIsSyncing(true);

      const history = JSON.parse(localStorage.getItem("chatHistory") || "[]");

      if (history.length === 0) {
        console.log("Aucun historique à synchroniser");
        return;
      }

      // Filtrer uniquement les entrées non synchronisées
      const unsyncedHistory = history.filter(
        (item) => !item.synced && item.sales_center_id === salesCenter.id
      );

      if (unsyncedHistory.length === 0) {
        console.log("Tout l'historique est déjà synchronisé");
        return;
      }

      console.log(`🔄 Synchronisation de ${unsyncedHistory.length} entrées...`);

      const formattedData = formatHistoryForSync(
        unsyncedHistory,
        salesCenter.id
      );
      await syncAnalytics(formattedData);

      // Marquer les entrées comme synchronisées
      const updatedHistory = history.map((item) => {
        if (unsyncedHistory.some((u) => u.timestamp === item.timestamp)) {
          return { ...item, synced: true };
        }
        return item;
      });

      localStorage.setItem("chatHistory", JSON.stringify(updatedHistory));

      console.log("✅ Synchronisation réussie");
    } catch (error) {
      console.error("❌ Erreur synchronisation:", error);
    } finally {
      setIsSyncing(false);
    }
  };

  // 🆕 Définir le centre de vente
  const selectSalesCenter = (center) => {
    setSalesCenter(center);
    localStorage.setItem("salesCenter", JSON.stringify(center));
  };

  // 🆕 Supprimer le centre de vente (déconnexion)
  const clearSalesCenter = () => {
    setSalesCenter(null);
    localStorage.removeItem("salesCenter");
  };

  const updateMessageFeedback = (messageId, feedback) => {
    setMessages((prev) =>
      prev.map((msg) => (msg.id === messageId ? { ...msg, feedback } : msg))
    );

    try {
      const feedbacks = JSON.parse(localStorage.getItem("feedbacks") || "[]");
      feedbacks.push({ messageId, feedback, timestamp: new Date() });
      localStorage.setItem("feedbacks", JSON.stringify(feedbacks));
    } catch (error) {
      console.error("Erreur lors de la sauvegarde du feedback:", error);
    }
  };

  const clearHistory = () => {
    localStorage.removeItem("chatHistory");
    localStorage.removeItem("feedbacks");
    setMessages([welcomeMessage]);
  };

  const reloadHistory = () => {
    try {
      const history = JSON.parse(localStorage.getItem("chatHistory") || "[]");

      if (history.length === 0) {
        setMessages([welcomeMessage]);
        return;
      }

      const loadedMessages = [welcomeMessage];

      history.forEach((item, index) => {
        loadedMessages.push({
          id: `user-${index}-${Date.now()}`,
          type: "user",
          content: item.question,
          timestamp: new Date(item.timestamp),
        });

        loadedMessages.push({
          id: `assistant-${index}-${Date.now()}`,
          type: "assistant",
          content: item.answer,
          sources: item.sources,
          timestamp: new Date(item.timestamp),
          feedback: null,
        });
      });

      setMessages(loadedMessages);
    } catch (error) {
      console.error("Erreur lors du rechargement:", error);
    }
  };

  const value = {
    messages,
    setMessages,
    addMessage,
    saveToHistory,
    updateMessageFeedback,
    clearHistory,
    reloadHistory,
    salesCenter,
    selectSalesCenter,
    clearSalesCenter,
    syncHistoryToBackend,
    isSyncing,
  };

  return <ChatContext.Provider value={value}>{children}</ChatContext.Provider>;
}
