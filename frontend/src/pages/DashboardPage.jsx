// src/pages/DashboardPage.jsx - VERSION FINALE CORRIGÉE
import React, { useState, useEffect } from "react";
import {
  MessageSquare,
  ThumbsUp,
  ThumbsDown,
  TrendingUp,
  FileText,
  Clock,
  BarChart3,
  PieChart as PieChartIcon,
  Store,
  RefreshCw,
  Loader2,
  AlertCircle,
} from "lucide-react";
import {
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from "recharts";
import { getDashboardStats, getCentersPerformance } from "../services/api";

const DashboardPage = () => {
  // ❌ NE PAS utiliser salesCenter pour l'admin
  // const { salesCenter } = useChatContext();

  // États
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const [periodDays, setPeriodDays] = useState(30);

  const [stats, setStats] = useState({
    totalConversations: 0,
    positiveFeedbacks: 0,
    negativeFeedbacks: 0,
    satisfactionRate: 0,
    topSources: [],
    questionsPerDay: [],
    topQuestions: [],
    centerStats: [],
  });

  // ============================================
  // 📥 CHARGER LES DONNÉES DEPUIS L'API
  // ============================================
  const loadDashboardData = async () => {
    setIsLoading(true);
    setError(null);

    try {
      // 1. Charger les stats générales (TOUJOURS null = toutes les conversations)
      const statsResponse = await getDashboardStats(null, periodDays);

      if (statsResponse.status === "success") {
        const data = statsResponse.data;

        // 2. Charger les performances des centres
        const centersResponse = await getCentersPerformance(periodDays);

        setStats({
          totalConversations: data.total_conversations || 0,
          positiveFeedbacks: data.positive_feedbacks || 0,
          negativeFeedbacks: data.negative_feedbacks || 0,
          satisfactionRate: data.satisfaction_rate || 0,
          topSources: data.top_sources || [],
          questionsPerDay: data.questions_per_day || [],
          topQuestions: data.top_questions || [],
          centerStats: centersResponse.data || [],
        });
      }
    } catch (err) {
      console.error("❌ Erreur chargement dashboard:", err);
      setError(
        "Impossible de charger les statistiques. Vérifiez votre connexion."
      );
    } finally {
      setIsLoading(false);
    }
  };

  // Charger au montage et quand la période change
  useEffect(() => {
    loadDashboardData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [periodDays]);

  // ============================================
  // 📊 DONNÉES POUR LES GRAPHIQUES
  // ============================================
  const feedbackData = [
    {
      name: "Positif",
      value: stats.positiveFeedbacks,
      color: "#4B8A34",
    },
    {
      name: "Négatif",
      value: stats.negativeFeedbacks,
      color: "#ef4444",
    },
  ];

  // ============================================
  // 🎨 RENDU - CHARGEMENT
  // ============================================
  if (isLoading) {
    return (
      <div className="h-full flex items-center justify-center bg-gradient-to-br from-gray-50 via-white to-gray-50">
        <div className="text-center">
          <Loader2 className="w-16 h-16 animate-spin text-[#4B8A34] mx-auto mb-4" />
          <p className="text-lg font-semibold text-gray-700">
            Chargement des statistiques...
          </p>
          <p className="text-sm text-gray-500 mt-2">
            Récupération des données depuis la base de données
          </p>
        </div>
      </div>
    );
  }

  // ============================================
  // 🎨 RENDU - ERREUR
  // ============================================
  if (error) {
    return (
      <div className="h-full flex items-center justify-center bg-gradient-to-br from-gray-50 via-white to-gray-50">
        <div className="text-center max-w-md">
          <AlertCircle className="w-16 h-16 text-red-500 mx-auto mb-4" />
          <h2 className="text-xl font-bold text-gray-900 mb-2">
            Erreur de chargement
          </h2>
          <p className="text-gray-600 mb-6">{error}</p>
          <button
            onClick={loadDashboardData}
            className="px-6 py-3 bg-gradient-to-r from-[#4B8A34] to-[#5a9d40] text-white rounded-lg hover:from-[#5a9d40] hover:to-[#4B8A34] transition-all font-semibold"
          >
            Réessayer
          </button>
        </div>
      </div>
    );
  }

  // ============================================
  // 🎨 RENDU - DASHBOARD
  // ============================================
  return (
    <div className="h-full overflow-y-auto bg-gradient-to-br from-gray-50 via-white to-gray-50">
      <div className="max-w-7xl mx-auto p-6 space-y-6">
        {/* ========== HEADER ========== */}
        <div className="bg-gradient-to-r from-[#4B8A34] to-[#5a9d40] rounded-2xl p-8 text-white shadow-lg">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h1 className="text-3xl font-bold mb-2">Dashboard Analytics</h1>
              <p className="text-white/90">
                Statistiques globales - Tous les centres de vente
              </p>
              <div className="mt-3 flex items-center gap-2 text-white/90">
                <Store size={18} />
                <span className="font-semibold">Vue Administrateur</span>
              </div>
            </div>

            {/* Contrôles */}
            <div className="flex flex-col gap-3">
              {/* Sélecteur de période */}
              <select
                value={periodDays}
                onChange={(e) => setPeriodDays(Number(e.target.value))}
                className="px-4 py-2 rounded-lg bg-white/20 text-white font-semibold cursor-pointer hover:bg-white/30 transition-all"
              >
                <option value={7} className="text-gray-900">
                  7 derniers jours
                </option>
                <option value={30} className="text-gray-900">
                  30 derniers jours
                </option>
                <option value={90} className="text-gray-900">
                  90 derniers jours
                </option>
              </select>

              {/* Bouton rafraîchir */}
              <button
                onClick={loadDashboardData}
                disabled={isLoading}
                className="px-4 py-2 rounded-lg bg-white/20 text-white hover:bg-white/30 transition-all flex items-center justify-center gap-2 font-semibold disabled:opacity-50"
              >
                <RefreshCw
                  size={16}
                  className={isLoading ? "animate-spin" : ""}
                />
                Rafraîchir
              </button>
            </div>
          </div>
        </div>

        {/* ========== CARDS DE STATISTIQUES ========== */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <StatCard
            icon={MessageSquare}
            label="Total Conversations"
            value={stats.totalConversations}
            color="from-[#4B8A34] to-[#5a9d40]"
            subtitle={`Sur ${periodDays} jours`}
          />
          <StatCard
            icon={ThumbsUp}
            label="Feedback Positifs"
            value={stats.positiveFeedbacks}
            color="from-green-500 to-green-600"
            subtitle="Satisfait"
          />
          <StatCard
            icon={ThumbsDown}
            label="Feedback Négatifs"
            value={stats.negativeFeedbacks}
            color="from-red-500 to-red-600"
            subtitle="À améliorer"
          />
          <StatCard
            icon={BarChart3}
            label="Taux de Satisfaction"
            value={`${stats.satisfactionRate}%`}
            color="from-[#FFCC00] to-[#FFD633]"
            subtitle="Global"
          />
        </div>

        {/* ========== PERFORMANCE PAR CENTRE ========== */}
        {stats.centerStats.length > 0 && (
          <div className="bg-white rounded-xl p-6 shadow-md border-2 border-gray-100">
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-gradient-to-br from-[#4B8A34] to-[#5a9d40] rounded-lg flex items-center justify-center">
                  <Store size={20} className="text-white" />
                </div>
                <div>
                  <h2 className="text-lg font-bold text-gray-900">
                    Performance par Centre
                  </h2>
                  <p className="text-sm text-gray-600">
                    Classement des {stats.centerStats.length} centres les plus
                    actifs
                  </p>
                </div>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {stats.centerStats.slice(0, 10).map((center, index) => (
                <div
                  key={center.sales_center_id}
                  className="flex items-center gap-3 p-4 rounded-lg transition-all bg-gray-50 hover:bg-gray-100"
                >
                  <div className="flex-shrink-0 w-10 h-10 bg-gradient-to-br from-[#4B8A34] to-[#5a9d40] rounded-lg flex items-center justify-center">
                    <span className="text-lg font-bold text-white">
                      {index + 1}
                    </span>
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-bold text-gray-900 truncate">
                      {center.sales_center_name}
                    </p>
                    <p className="text-xs text-gray-600">{center.region}</p>
                  </div>
                  <div className="text-right">
                    <p className="text-xl font-bold text-[#4B8A34]">
                      {center.total_questions || 0}
                    </p>
                    <p className="text-xs text-gray-600">questions</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* ========== GRAPHIQUE QUESTIONS PAR JOUR ========== */}
          {stats.questionsPerDay.length > 0 && (
            <div className="bg-white rounded-xl p-6 shadow-md border-2 border-gray-100">
              <div className="flex items-center gap-3 mb-6">
                <div className="w-10 h-10 bg-gradient-to-br from-[#4B8A34] to-[#5a9d40] rounded-lg flex items-center justify-center">
                  <BarChart3 size={20} className="text-white" />
                </div>
                <div>
                  <h2 className="text-lg font-bold text-gray-900">
                    Questions par Jour
                  </h2>
                  <p className="text-sm text-gray-600">7 derniers jours</p>
                </div>
              </div>
              <ResponsiveContainer width="100%" height={250}>
                <BarChart data={stats.questionsPerDay}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                  <XAxis
                    dataKey="date"
                    tick={{ fontSize: 12, fill: "#666" }}
                    stroke="#ccc"
                  />
                  <YAxis tick={{ fontSize: 12, fill: "#666" }} stroke="#ccc" />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: "#fff",
                      border: "2px solid #4B8A34",
                      borderRadius: "8px",
                    }}
                  />
                  <Bar
                    dataKey="count"
                    fill="url(#colorGradient)"
                    radius={[8, 8, 0, 0]}
                  />
                  <defs>
                    <linearGradient
                      id="colorGradient"
                      x1="0"
                      y1="0"
                      x2="0"
                      y2="1"
                    >
                      <stop offset="0%" stopColor="#4B8A34" />
                      <stop offset="100%" stopColor="#5a9d40" />
                    </linearGradient>
                  </defs>
                </BarChart>
              </ResponsiveContainer>
            </div>
          )}

          {/* ========== GRAPHIQUE FEEDBACKS ========== */}
          <div className="bg-white rounded-xl p-6 shadow-md border-2 border-gray-100">
            <div className="flex items-center gap-3 mb-6">
              <div className="w-10 h-10 bg-gradient-to-br from-[#FFCC00] to-[#FFD633] rounded-lg flex items-center justify-center">
                <PieChartIcon size={20} className="text-gray-900" />
              </div>
              <div>
                <h2 className="text-lg font-bold text-gray-900">
                  Répartition des Feedbacks
                </h2>
                <p className="text-sm text-gray-600">
                  {stats.positiveFeedbacks + stats.negativeFeedbacks} feedbacks
                </p>
              </div>
            </div>

            {stats.positiveFeedbacks + stats.negativeFeedbacks > 0 ? (
              <ResponsiveContainer width="100%" height={250}>
                <PieChart>
                  <Pie
                    data={feedbackData}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={(entry) => `${entry.name}: ${entry.value}`}
                    outerRadius={80}
                    fill="#8884d8"
                    dataKey="value"
                  >
                    {feedbackData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip
                    contentStyle={{
                      backgroundColor: "#fff",
                      border: "2px solid #4B8A34",
                      borderRadius: "8px",
                    }}
                  />
                  <Legend
                    wrapperStyle={{ fontSize: "14px", fontWeight: "600" }}
                  />
                </PieChart>
              </ResponsiveContainer>
            ) : (
              <div className="h-[250px] flex items-center justify-center text-gray-400">
                <div className="text-center">
                  <ThumbsUp size={48} className="mx-auto mb-3 text-gray-300" />
                  <p className="font-medium">Aucun feedback pour le moment</p>
                </div>
              </div>
            )}
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* ========== SOURCES LES PLUS UTILISÉES ========== */}
          <div className="bg-white rounded-xl p-6 shadow-md border-2 border-gray-100">
            <div className="flex items-center gap-3 mb-6">
              <div className="w-10 h-10 bg-gradient-to-br from-[#4B8A34] to-[#5a9d40] rounded-lg flex items-center justify-center">
                <FileText size={20} className="text-white" />
              </div>
              <div>
                <h2 className="text-lg font-bold text-gray-900">
                  Sources les Plus Utilisées
                </h2>
                <p className="text-sm text-gray-600">Top 5 documents</p>
              </div>
            </div>

            {stats.topSources.length > 0 ? (
              <div className="space-y-3">
                {stats.topSources.map((source, index) => (
                  <div key={index} className="flex items-center gap-3">
                    <div className="flex-shrink-0 w-8 h-8 bg-gradient-to-br from-[#4B8A34]/10 to-[#FFCC00]/10 rounded-lg flex items-center justify-center">
                      <span className="text-sm font-bold text-[#4B8A34]">
                        {index + 1}
                      </span>
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-semibold text-gray-900 truncate">
                        {source.name}
                      </p>
                      <div className="mt-1 bg-gray-100 rounded-full h-2 overflow-hidden">
                        <div
                          className="h-full bg-gradient-to-r from-[#4B8A34] to-[#5a9d40] rounded-full transition-all"
                          style={{
                            width: `${Math.min(
                              (source.count / stats.totalConversations) * 100,
                              100
                            )}%`,
                          }}
                        />
                      </div>
                    </div>
                    <div className="flex-shrink-0">
                      <span className="text-sm font-bold text-gray-900">
                        {source.count}
                      </span>
                      <span className="text-xs text-gray-500 ml-1">fois</span>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="text-center text-gray-400 py-8">
                <FileText size={48} className="mx-auto mb-3 text-gray-300" />
                <p className="font-medium">Aucune source utilisée</p>
              </div>
            )}
          </div>

          {/* ========== QUESTIONS LES PLUS FRÉQUENTES ========== */}
          <div className="bg-white rounded-xl p-6 shadow-md border-2 border-gray-100">
            <div className="flex items-center gap-3 mb-6">
              <div className="w-10 h-10 bg-gradient-to-br from-[#FFCC00] to-[#FFD633] rounded-lg flex items-center justify-center">
                <MessageSquare size={20} className="text-gray-900" />
              </div>
              <div>
                <h2 className="text-lg font-bold text-gray-900">
                  Questions Fréquentes
                </h2>
                <p className="text-sm text-gray-600">Top 5 questions</p>
              </div>
            </div>

            {stats.topQuestions.length > 0 ? (
              <div className="space-y-4">
                {stats.topQuestions.map((item, index) => (
                  <div
                    key={index}
                    className="flex items-start gap-3 p-3 bg-gradient-to-r from-[#4B8A34]/5 to-[#FFCC00]/5 rounded-lg hover:from-[#4B8A34]/10 hover:to-[#FFCC00]/10 transition-all"
                  >
                    <div className="flex-shrink-0 w-6 h-6 bg-gradient-to-br from-[#4B8A34] to-[#5a9d40] rounded-md flex items-center justify-center">
                      <span className="text-xs font-bold text-white">
                        {index + 1}
                      </span>
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-gray-900 line-clamp-2">
                        {item.question}
                      </p>
                      <p className="text-xs text-gray-600 mt-1 flex items-center gap-1">
                        <Clock size={12} />
                        Demandée {item.count} fois
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="text-center text-gray-400 py-8">
                <MessageSquare
                  size={48}
                  className="mx-auto mb-3 text-gray-300"
                />
                <p className="font-medium">Aucune question enregistrée</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default DashboardPage;

// ============================================
// 📊 COMPOSANT STATCARD
// ============================================
const StatCard = ({ icon, label, value, color, trend, subtitle }) => {
  const Icon = icon;

  return (
    <div className="bg-white rounded-xl p-6 shadow-md border-2 border-gray-100 hover:shadow-lg transition-all">
      <div className="flex items-start justify-between mb-4">
        <div
          className={`w-12 h-12 rounded-xl flex items-center justify-center bg-gradient-to-br ${color} shadow-lg`}
        >
          <Icon size={24} className="text-white" />
        </div>
        {trend && (
          <div className="flex items-center gap-1 text-xs font-semibold text-green-600">
            <TrendingUp size={14} />
            {trend}
          </div>
        )}
      </div>
      <div>
        <p className="text-3xl font-bold text-gray-900 mb-1">{value}</p>
        <p className="text-sm text-gray-900 font-medium">{label}</p>
        {subtitle && <p className="text-xs text-gray-500 mt-1">{subtitle}</p>}
      </div>
    </div>
  );
};
