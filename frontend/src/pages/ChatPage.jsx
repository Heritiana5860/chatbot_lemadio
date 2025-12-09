import React, { useState, useRef, useEffect } from "react";
import {
  Send,
  ThumbsUp,
  ThumbsDown,
  Loader2,
  FileText,
  Sparkles,
  Zap,
  LogIn,
  Wallet,
  Package,
  XCircle,
} from "lucide-react";
import { format } from "date-fns";
import { fr } from "date-fns/locale";
import { sendMessage } from "../services/api";
import { useChatContext } from "../contextes/UseChatContext";

const ChatPage = () => {
  const { messages, addMessage, saveToHistory, updateMessageFeedback } =
    useChatContext();

  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const messagesEndRef = useRef(null);
  const inputRef = useRef(null);

  const suggestedQuestions = [
    {
      icon: LogIn,
      text: "Comment s'authentifier ?",
    },
    {
      icon: Wallet,
      text: "Comment créer une vente ?",
    },
    {
      icon: Package,
      text: "Comment gérer le stock ?",
    },
    {
      icon: XCircle,
      text: "Comment annuler une vente ?",
    },
  ];

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSend = async (question = input) => {
    if (!question.trim() || loading) return;

    const userMessage = {
      id: Date.now(),
      type: "user",
      content: question,
      timestamp: new Date(),
    };

    addMessage(userMessage);
    setInput("");
    setLoading(true);

    try {
      // 🆕 Utiliser le service API au lieu d'axios direct
      const response = await sendMessage(question);

      const assistantMessage = {
        id: Date.now() + 1,
        type: "assistant",
        content: response.answer || "Je n'ai pas pu récupérer de réponse.",
        sources: response.sources || [],
        timestamp: response.timestamp
          ? new Date(response.timestamp)
          : new Date(),
        feedback: null,
      };

      addMessage(assistantMessage);
      saveToHistory(userMessage, assistantMessage);
    } catch (error) {
      console.error("Erreur lors de l'envoi:", error);
      const errorMessage = {
        id: Date.now() + 1,
        type: "assistant",
        content: "Désolé, une erreur s'est produite. Veuillez réessayer.",
        timestamp: new Date(),
        isError: true,
      };
      addMessage(errorMessage);
    } finally {
      setLoading(false);
      inputRef.current?.focus();
    }
  };

  const handleFeedback = (messageId, feedback) => {
    updateMessageFeedback(messageId, feedback);
  };

  const handleKeyPress = (e) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  return (
    <div className="flex flex-col h-full bg-gradient-to-br from-gray-50 via-white to-gray-50">
      {/* Zone des messages */}
      <div className="flex-1 overflow-y-auto px-4 py-8">
        <div className="max-w-4xl mx-auto space-y-6">
          {messages.map((message) => (
            <div
              key={message.id}
              className={`flex ${
                message.type === "user" ? "justify-end" : "justify-start"
              }`}
            >
              <div
                className={`flex gap-3 max-w-3xl ${
                  message.type === "user" ? "flex-row-reverse" : ""
                }`}
              >
                {/* Avatar moderne */}
                <div
                  className={`flex-shrink-0 w-10 h-10 rounded-xl flex items-center justify-center shadow-md ${
                    message.type === "user"
                      ? "bg-gradient-to-br from-[#4B8A34] to-[#5a9d40]"
                      : message.isError
                      ? "bg-gradient-to-br from-red-500 to-red-600"
                      : "bg-white border-2 border-[#4B8A34]"
                  }`}
                >
                  {message.type === "user" ? (
                    <span className="text-white text-sm font-bold">V</span>
                  ) : (
                    <Sparkles size={18} className="text-[#4B8A34]" />
                  )}
                </div>

                {/* Contenu du message */}
                <div
                  className={`flex-1 ${
                    message.type === "user" ? "text-right" : ""
                  }`}
                >
                  <div
                    className={`inline-block px-5 py-4 rounded-2xl shadow-sm ${
                      message.type === "user"
                        ? "bg-gradient-to-br from-[#4B8A34] to-[#5a9d40] text-white"
                        : message.isError
                        ? "bg-red-50 text-red-900 border border-red-200"
                        : "bg-white text-gray-900 border border-gray-100"
                    }`}
                  >
                    <p className="whitespace-pre-wrap text-sm leading-relaxed font-medium">
                      {message.content}
                    </p>

                    {/* Sources */}
                    {message.sources && message.sources.length > 0 && (
                      <div className="mt-4 pt-4 border-t border-gray-200">
                        <div className="flex items-center gap-2 text-xs text-gray-600 mb-3">
                          <FileText size={14} className="text-[#4B8A34]" />
                          <span className="font-semibold">Sources :</span>
                        </div>
                        <div className="flex flex-wrap gap-2">
                          {message.sources.map((source, idx) => (
                            <span
                              key={idx}
                              className="inline-flex items-center px-3 py-1.5 rounded-lg bg-gradient-to-r from-[#4B8A34]/10 to-[#FFCC00]/10 text-[#4B8A34] text-xs font-semibold border border-[#4B8A34]/20"
                            >
                              {source.split(".")[0]}
                            </span>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>

                  {/* Horodatage + feedback */}
                  <div
                    className={`flex items-center gap-3 mt-2 ${
                      message.type === "user" ? "justify-end" : ""
                    }`}
                  >
                    <span className="text-xs text-gray-500 font-medium">
                      {format(message.timestamp, "HH:mm", { locale: fr })}
                    </span>

                    {message.type === "assistant" && !message.isError && (
                      <div className="flex gap-1.5">
                        <button
                          onClick={() => handleFeedback(message.id, "positive")}
                          className={`p-2 rounded-lg transition-all duration-200 ${
                            message.feedback === "positive"
                              ? "bg-[#4B8A34]/10 text-[#4B8A34] scale-110"
                              : "text-gray-400 hover:bg-gray-100 hover:text-[#4B8A34] hover:scale-105"
                          }`}
                        >
                          <ThumbsUp size={14} />
                        </button>
                        <button
                          onClick={() => handleFeedback(message.id, "negative")}
                          className={`p-2 rounded-lg transition-all duration-200 ${
                            message.feedback === "negative"
                              ? "bg-red-100 text-red-600 scale-110"
                              : "text-gray-400 hover:bg-gray-100 hover:text-red-600 hover:scale-105"
                          }`}
                        >
                          <ThumbsDown size={14} />
                        </button>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            </div>
          ))}

          {/* Indicateur de chargement */}
          {loading && (
            <div className="flex justify-start">
              <div className="flex gap-3 max-w-3xl">
                <div className="flex-shrink-0 w-10 h-10 rounded-xl bg-white border-2 border-[#4B8A34] flex items-center justify-center shadow-md">
                  <Sparkles size={18} className="text-[#4B8A34]" />
                </div>
                <div className="inline-block px-5 py-4 rounded-2xl bg-white border border-gray-100 shadow-sm">
                  <div className="flex items-center gap-3 text-gray-600">
                    <Loader2
                      size={18}
                      className="animate-spin text-[#4B8A34]"
                    />
                    <span className="text-sm font-medium">
                      Recherche en cours...
                    </span>
                    <div className="flex gap-1">
                      <div className="w-1.5 h-1.5 bg-[#4B8A34] rounded-full animate-bounce"></div>
                      <div
                        className="w-1.5 h-1.5 bg-[#FFCC00] rounded-full animate-bounce"
                        style={{ animationDelay: "0.1s" }}
                      ></div>
                      <div
                        className="w-1.5 h-1.5 bg-[#4B8A34] rounded-full animate-bounce"
                        style={{ animationDelay: "0.2s" }}
                      ></div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          <div ref={messagesEndRef} />
        </div>
      </div>

      {/* Questions suggérées */}
      {messages.length === 1 && (
        <div className="px-4 pb-6">
          <div className="max-w-4xl mx-auto">
            <div className="flex items-center gap-2 mb-4">
              <Zap size={18} className="text-[#FFCC00]" />
              <p className="text-sm text-gray-700 font-semibold">
                Questions rapides :
              </p>
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              {suggestedQuestions.map((q, idx) => {
                const Icon = q.icon;
                return (
                  <button
                    key={idx}
                    onClick={() => handleSend(q.text)}
                    className="group relative text-left px-5 py-4 bg-gradient-to-r from-[#4B8A34]/10 to-[#FFCC00]/10 border-2 border-transparent rounded-xl hover:border-[#4B8A34] hover:shadow-md transition-all duration-200 transform hover:-translate-y-1"
                  >
                    <div className="flex items-center gap-3">
                      <Icon size={22} className="text-[#4B8A34]" />
                      <span className="text-sm font-semibold text-gray-700 group-hover:text-[#4B8A34] transition-colors">
                        {q.text}
                      </span>
                    </div>
                  </button>
                );
              })}
            </div>
          </div>
        </div>
      )}

      {/* Zone de saisie */}
      <div className="border-t border-gray-200 bg-white px-4 py-6 shadow-lg">
        <div className="max-w-4xl mx-auto">
          <div className="flex gap-3">
            <textarea
              ref={inputRef}
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={handleKeyPress}
              placeholder="Tapez votre question ici..."
              rows={1}
              className="flex-1 px-5 py-4 border-2 border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#4B8A34] focus:border-transparent resize-none shadow-sm hover:border-[#4B8A34]/50 transition-all duration-200 font-medium"
              style={{ minHeight: "56px", maxHeight: "120px" }}
            />
            <button
              onClick={() => handleSend()}
              disabled={!input.trim() || loading}
              className="px-8 py-4 bg-gradient-to-r from-[#4B8A34] to-[#5a9d40] text-white rounded-xl hover:from-[#5a9d40] hover:to-[#4B8A34] disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 flex items-center gap-3 font-bold shadow-md hover:shadow-lg transform hover:-translate-y-0.5 disabled:transform-none"
            >
              <Send size={20} />
              <span className="hidden sm:inline">Envoyer</span>
            </button>
          </div>
          <p className="text-xs text-gray-500 mt-3 text-center font-medium">
            Appuyez sur{" "}
            <kbd className="px-2 py-0.5 bg-gray-100 rounded border border-gray-300 text-[#4B8A34] font-semibold">
              Entrée
            </kbd>{" "}
            pour envoyer
          </p>
        </div>
      </div>
    </div>
  );
};

export default ChatPage;
