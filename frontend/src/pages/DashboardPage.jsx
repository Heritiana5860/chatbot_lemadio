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
import { format, startOfDay, subDays } from "date-fns";
import { fr } from "date-fns/locale";

const COLORS = ["#4B8A34", "#FFCC00", "#5a9d40", "#FFD633"];

const DashboardPage = () => {
  const [stats, setStats] = useState({
    totalConversations: 0,
    positiveFeedbacks: 0,
    negativeFeedbacks: 0,
    averageResponseTime: 0,
    topSources: [],
    questionsPerDay: [],
    topQuestions: [],
  });

  const calculateStats = () => {
    // Charger l'historique
    const history = JSON.parse(localStorage.getItem("chatHistory") || "[]");
    const feedbacks = JSON.parse(localStorage.getItem("feedbacks") || "[]");

    // Statistiques de base
    const totalConversations = history.length;
    const positiveFeedbacks = feedbacks.filter(
      (f) => f.feedback === "positive"
    ).length;
    const negativeFeedbacks = feedbacks.filter(
      (f) => f.feedback === "negative"
    ).length;

    // Sources les plus utilisées
    const sourcesMap = {};
    history.forEach((item) => {
      if (item.sources) {
        item.sources.forEach((source) => {
          sourcesMap[source] = (sourcesMap[source] || 0) + 1;
        });
      }
    });
    const topSources = Object.entries(sourcesMap)
      .map(([name, count]) => ({ name, count }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 5);

    // Questions par jour (7 derniers jours)
    const last7Days = [];
    for (let i = 6; i >= 0; i--) {
      const date = startOfDay(subDays(new Date(), i));
      const count = history.filter((item) => {
        const itemDate = startOfDay(new Date(item.timestamp));
        return itemDate.getTime() === date.getTime();
      }).length;
      last7Days.push({
        date: format(date, "dd MMM", { locale: fr }),
        count,
      });
    }

    // Questions les plus fréquentes
    const questionsMap = {};
    history.forEach((item) => {
      const question = item.question.toLowerCase().trim();
      questionsMap[question] = (questionsMap[question] || 0) + 1;
    });
    const topQuestions = Object.entries(questionsMap)
      .map(([question, count]) => ({ question, count }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 5);

    setStats({
      totalConversations,
      positiveFeedbacks,
      negativeFeedbacks,
      averageResponseTime: 0,
      topSources,
      questionsPerDay: last7Days,
      topQuestions,
    });
  };

  useEffect(() => {
    setTimeout(() => {
      calculateStats();
    }, 0);
  }, []);

  const satisfactionRate =
    stats.totalConversations > 0
      ? Math.round(
          (stats.positiveFeedbacks /
            (stats.positiveFeedbacks + stats.negativeFeedbacks || 1)) *
            100
        )
      : 0;

  const feedbackData = [
    { name: "Positif", value: stats.positiveFeedbacks, color: "#4B8A34" },
    { name: "Négatif", value: stats.negativeFeedbacks, color: "#ef4444" },
  ];

  return (
    <div className="h-full overflow-y-auto bg-gradient-to-br from-gray-50 via-white to-gray-50">
      <div className="max-w-7xl mx-auto p-6 space-y-6">
        {/* Header */}
        <div className="bg-gradient-to-r from-[#4B8A34] to-[#5a9d40] rounded-2xl p-8 text-white shadow-lg">
          <h1 className="text-3xl font-bold mb-2">Dashboard</h1>
          <p className="text-white/90">
            Vue d'ensemble des statistiques de formation Lemadio
          </p>
        </div>

        {/* Cards de statistiques */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <StatCard
            icon={MessageSquare}
            label="Total Conversations"
            value={stats.totalConversations}
            color="from-[#4B8A34] to-[#5a9d40]"
          />
          <StatCard
            icon={ThumbsUp}
            label="Feedback Positifs"
            value={stats.positiveFeedbacks}
            color="from-green-500 to-green-600"
            trend="+12%"
          />
          <StatCard
            icon={ThumbsDown}
            label="Feedback Négatifs"
            value={stats.negativeFeedbacks}
            color="from-red-500 to-red-600"
          />
          <StatCard
            icon={BarChart3}
            label="Taux de Satisfaction"
            value={`${satisfactionRate}%`}
            color="from-[#FFCC00] to-[#FFD633]"
          />
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Graphique Questions par jour */}
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
                    fontSize: "12px",
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

          {/* Graphique Répartition Feedback */}
          <div className="bg-white rounded-xl p-6 shadow-md border-2 border-gray-100">
            <div className="flex items-center gap-3 mb-6">
              <div className="w-10 h-10 bg-gradient-to-br from-[#FFCC00] to-[#FFD633] rounded-lg flex items-center justify-center">
                <PieChartIcon size={20} className="text-gray-900" />
              </div>
              <div>
                <h2 className="text-lg font-bold text-gray-900">
                  Répartition des Feedbacks
                </h2>
                <p className="text-sm text-gray-600">Satisfaction globale</p>
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
                      fontSize: "12px",
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
          {/* Sources les plus utilisées */}
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
                            width: `${
                              (source.count / stats.totalConversations) * 100
                            }%`,
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

          {/* Questions les plus fréquentes */}
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
                    className="flex items-start gap-3 p-3 bg-gradient-to-r from-[#4B8A34]/5 to-[#FFCC00]/5 rounded-lg"
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
                      <p className="text-xs text-gray-600 mt-1">
                        <Clock size={12} className="inline mr-1" />
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

const StatCard = ({ icon, label, value, color, trend }) => {
  const Icon = icon;

  return (
    <div className="bg-white rounded-xl p-6 shadow-md border-2 border-gray-100 hover:shadow-lg transition-all">
      <div className="flex items-start justify-between mb-4">
        <div
          className={`w-12 h-12 rounded-xl flex items-center justify-center bg-gradient-to-br ${color}`}
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
        <p className="text-sm text-gray-600 font-medium">{label}</p>
      </div>
    </div>
  );
};
