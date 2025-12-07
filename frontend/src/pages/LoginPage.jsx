import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Lock, User, AlertCircle, Eye, EyeOff, Loader2 } from "lucide-react";
import { login } from "../services/api";

const LoginPage = () => {
  const navigate = useNavigate();
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      const response = await login(username, password);

      // Sauvegarder le token
      localStorage.setItem("admin_token", response.access_token);
      localStorage.setItem("admin_username", response.username);

      // Rediriger vers le dashboard
      navigate("/dashboard");
    } catch (err) {
      console.error("Erreur login:", err);
      setError(
        err.response?.data?.detail ||
          "Identifiants incorrects. Veuillez réessayer."
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#3D6E2A] flex items-center justify-center p-4">
      {/* Particules d'arrière-plan */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute w-96 h-96 bg-[#FFCC00]/10 rounded-full blur-3xl -top-48 -left-48 animate-pulse"></div>
        <div className="absolute w-96 h-96 bg-white/5 rounded-full blur-3xl -bottom-48 -right-48 animate-pulse delay-700"></div>
      </div>

      <div className="relative w-full max-w-md">
        {/* Card principale */}
        <div className="bg-white rounded-3xl shadow-2xl overflow-hidden">
          {/* Header avec gradient */}
          <div className="bg-[#3D6E2A] px-8 py-12 text-center relative overflow-hidden">
            <div className="absolute inset-0 bg-white/5"></div>
            <div className="relative z-10">
              {/* Logo */}
              <div className="w-20 h-20 bg-white rounded-2xl mx-auto mb-4 flex items-center justify-center shadow-lg">
                <img
                  src="LOGO-ADES_HD.png"
                  alt="Logo Lemadio"
                  className="w-16 h-16 object-contain"
                />
              </div>
              <h1 className="text-3xl font-bold text-white mb-2">
                Lemadio Admin
              </h1>
              <p className="text-white/90 text-sm font-medium">
                Espace réservé aux administrateurs
              </p>
            </div>
          </div>

          {/* Formulaire */}
          <div className="px-8 py-10">
            {error && (
              <div className="mb-6 p-4 bg-red-50 border-l-4 border-red-500 rounded-lg flex items-start gap-3">
                <AlertCircle
                  size={20}
                  className="text-red-500 flex-shrink-0 mt-0.5"
                />
                <p className="text-sm text-red-800 font-medium">{error}</p>
              </div>
            )}

            <form onSubmit={handleSubmit} className="space-y-6">
              {/* Nom d'utilisateur */}
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Nom d'utilisateur
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                    <User size={20} className="text-gray-400" />
                  </div>
                  <input
                    type="text"
                    value={username}
                    onChange={(e) => setUsername(e.target.value)}
                    placeholder="admin"
                    required
                    className="w-full pl-12 pr-4 py-3.5 border-2 border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#4B8A34] focus:border-transparent transition-all font-medium"
                  />
                </div>
              </div>

              {/* Mot de passe */}
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Mot de passe
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                    <Lock size={20} className="text-gray-400" />
                  </div>
                  <input
                    type={showPassword ? "text" : "password"}
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="••••••••"
                    required
                    className="w-full pl-12 pr-12 py-3.5 border-2 border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#4B8A34] focus:border-transparent transition-all font-medium"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute inset-y-0 right-0 pr-4 flex items-center text-gray-400 hover:text-gray-600 transition-colors"
                  >
                    {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                  </button>
                </div>
              </div>

              {/* Bouton de connexion */}
              <button
                type="submit"
                disabled={loading}
                className="w-full bg-[#3D6E2A] text-white py-4 rounded-xl font-bold text-lg shadow-lg cursor-pointer hover:shadow-xl hover:bg-[#5a9d40] hover:bg-[#4B8A34] disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 flex items-center justify-center gap-3"
              >
                {loading ? (
                  <>
                    <Loader2 size={24} className="animate-spin" />
                    <span>Connexion en cours...</span>
                  </>
                ) : (
                  <>
                    <Lock size={24} />
                    <span>Se connecter</span>
                  </>
                )}
              </button>
            </form>

            {/* Info connexion de test */}
            {/* <div className="mt-8 p-4 bg-gradient-to-r from-[#4B8A34]/5 to-[#FFCC00]/5 rounded-xl border-2 border-[#4B8A34]/10">
              <p className="text-xs text-gray-600 font-semibold mb-2 text-center">
                🔐 Comptes de test
              </p>
              <div className="space-y-1 text-xs text-gray-600 text-center">
                <p>
                  <strong>Admin:</strong> admin / lemadio2025
                </p>
                <p>
                  <strong>Superviseur:</strong> supervisor / supervisor2025
                </p>
              </div>
            </div> */}
          </div>

          {/* Footer */}
          <div className="px-8 py-6 bg-gray-50 border-t border-gray-100">
            <div className="flex items-center justify-center gap-2 text-xs text-gray-500">
              <div className="w-2 h-2 bg-[#FFCC00] rounded-full"></div>
              <span className="font-medium">Lemadio Formation v2.0</span>
            </div>
          </div>
        </div>

        {/* Badge sécurisé */}
        <div className="mt-6 text-center">
          <div className="inline-flex items-center gap-2 px-4 py-2 bg-white/10 backdrop-blur-sm rounded-full border border-white/20">
            <Lock size={16} className="text-white" />
            <span className="text-sm font-semibold text-white">
              Connexion sécurisée
            </span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;
