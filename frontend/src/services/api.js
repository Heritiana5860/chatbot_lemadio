// src/services/api.js - VERSION COMPLÈTE FINALE
import axios from "axios";

// Configuration de base
const API_BASE_URL = import.meta.env.VITE_API_URL || "http://localhost:8080";

// Instance Axios configurée
const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
  timeout: 180000,
});

// Intercepteur pour ajouter le token JWT
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("admin_token");
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Intercepteur pour gérer les erreurs 401 (déconnexion auto)
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem("admin_token");
      localStorage.removeItem("admin_username");
      window.location.href = "/login";
    }
    console.log("API Error:", error.response?.data || error.message);
    console.error("API Error:", error.response?.data || error.message);
    return Promise.reject(error);
  }
);

// ============================================
// 🔐 AUTH
// ============================================

export const login = async (username, password) => {
  const response = await apiClient.post("/auth/login", {
    username,
    password,
  });
  console.log("Reponse: ", response.data);
  return response.data;
};

export const verifyAuth = async () => {
  const response = await apiClient.get("/auth/verify");
  return response.data;
};

export const logout = () => {
  localStorage.removeItem("admin_token");
  localStorage.removeItem("admin_username");
  window.location.href = "/login";
};

export const isAuthenticated = () => {
  return !!localStorage.getItem("admin_token");
};

// ============================================
// 💬 CHAT
// ============================================

export const sendMessage = async (question, conversationId = null) => {
  const response = await apiClient.post("/chat", {
    question,
    conversation_id: conversationId,
  });
  return response.data;
};

// ============================================
// 📊 ANALYTICS (PROTÉGÉ)
// ============================================

export const syncAnalytics = async (historyData) => {
  const response = await apiClient.post("/analytics/sync", {
    data: historyData,
    synced_at: new Date().toISOString(),
  });
  return response.data;
};

export const getReportsByCenter = async () => {
  const response = await apiClient.get("/analytics/reports/by-center");
  return response.data;
};

export const getFrequentQuestions = async () => {
  const response = await apiClient.get("/analytics/reports/frequent-questions");
  return response.data;
};

export const getSalesCenters = async () => {
  const response = await apiClient.get("/analytics/centers");
  return response.data;
};

// ============================================
// 📜 HISTORIQUE
// ============================================

export const getConversationHistory = async (
  salesCenterId = null,
  limit = 1000,
  offset = 0
) => {
  const params = new URLSearchParams();

  if (salesCenterId && salesCenterId !== "all") {
    params.append("sales_center_id", salesCenterId);
  }
  params.append("limit", limit.toString());
  params.append("offset", offset.toString());

  const response = await apiClient.get(
    `/analytics/history?${params.toString()}`
  );
  return response.data;
};

export const getHistoryStats = async (salesCenterId = null) => {
  const params = new URLSearchParams();

  if (salesCenterId && salesCenterId !== "all") {
    params.append("sales_center_id", salesCenterId);
  }

  const response = await apiClient.get(
    `/analytics/history/stats?${params.toString()}`
  );
  return response.data;
};

export const deleteConversation = async (conversationId) => {
  const response = await apiClient.delete(
    `/analytics/history/${conversationId}`
  );
  return response.data;
};

export const clearCenterHistory = async (salesCenterId) => {
  const response = await apiClient.delete(
    `/analytics/history/center/${salesCenterId}`
  );
  return response.data;
};

export const clearAllHistory = async () => {
  const response = await apiClient.delete(
    `/analytics/history/all?confirm=true`
  );
  return response.data;
};

// ============================================
// 📊 DASHBOARD ANALYTICS
// ============================================

export const getDashboardStats = async (salesCenterId = null, days = 30) => {
  const params = new URLSearchParams();

  if (salesCenterId) {
    params.append("sales_center_id", salesCenterId);
  }
  params.append("days", days.toString());

  const response = await apiClient.get(
    `/analytics/dashboard/stats?${params.toString()}`
  );
  return response.data;
};

export const getCentersPerformance = async (days = 30) => {
  const params = new URLSearchParams();
  params.append("days", days.toString());

  const response = await apiClient.get(
    `/analytics/dashboard/centers-performance?${params.toString()}`
  );
  return response.data;
};

export const getActivityTimeline = async (salesCenterId = null, days = 30) => {
  const params = new URLSearchParams();

  if (salesCenterId) {
    params.append("sales_center_id", salesCenterId);
  }
  params.append("days", days.toString());

  const response = await apiClient.get(
    `/analytics/dashboard/activity-timeline?${params.toString()}`
  );
  return response.data;
};

// ============================================
// ❤️ HEALTH & STATS
// ============================================

export const checkHealth = async () => {
  const response = await apiClient.get("/health");
  return response.data;
};

export const getSystemStats = async () => {
  const response = await apiClient.get("/stats");
  return response.data;
};

export const reindexDocuments = async () => {
  const response = await apiClient.post("/reindex");
  return response.data;
};

// ============================================
// 🛠️ UTILITAIRES
// ============================================

export const testConnection = async () => {
  try {
    await checkHealth();
    return true;
  } catch (error) {
    console.log(error);
    return false;
  }
};

export const formatHistoryForSync = (history, salesCenterId) => {
  return history.map((item) => ({
    question: item.question,
    answer: item.answer,
    sources: JSON.stringify(item.sources || []),
    timestamp: item.timestamp,
    sales_center_id: salesCenterId,
  }));
};

// ============================================
// 📤 EXPORT PAR DÉFAUT
// ============================================

export default {
  // Auth
  login,
  verifyAuth,
  logout,
  isAuthenticated,

  // Chat
  sendMessage,

  // Analytics
  syncAnalytics,
  getReportsByCenter,
  getFrequentQuestions,
  getSalesCenters,

  // Historique
  getConversationHistory,
  getHistoryStats,
  deleteConversation,
  clearCenterHistory,
  clearAllHistory,

  // Dashboard
  getDashboardStats,
  getCentersPerformance,
  getActivityTimeline,

  // Health & Stats
  checkHealth,
  getSystemStats,
  reindexDocuments,

  // Utilitaires
  testConnection,
  formatHistoryForSync,
};
