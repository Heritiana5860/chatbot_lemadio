import React, { useState } from "react";
import { Link, useLocation } from "react-router-dom";
import {
  MessageSquare,
  History,
  BarChart3,
  Menu,
  X,
  Leaf,
  LogOut,
  User,
} from "lucide-react";
import { logout } from "../services/api";

const Layout = ({ children }) => {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const location = useLocation();
  const username = localStorage.getItem("admin_username") || "Admin";

  const navigation = [
    { name: "Dashboard", href: "/dashboard", icon: BarChart3 },
    { name: "Historique", href: "/history", icon: History },
    { name: "Formation", href: "/chat", icon: MessageSquare },
  ];

  const isActive = (path) => location.pathname === path;

  const handleLogout = () => {
    if (window.confirm("Voulez-vous vraiment vous déconnecter ?")) {
      logout();
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-gradient-to-r from-[#4B8A34] to-[#5a9d40] shadow-lg sticky top-0 z-40 border-b-2 border-[#FFCC00]">
        <div className="flex items-center justify-between px-6 py-3">
          <div className="flex items-center">
            <button
              onClick={() => setSidebarOpen(!sidebarOpen)}
              className="lg:hidden mr-4 p-2 rounded-lg text-white hover:bg-white/20 transition-all duration-200"
            >
              {sidebarOpen ? <X size={24} /> : <Menu size={24} />}
            </button>
            <div className="flex items-center space-x-3">
              <div className="relative w-12 h-12 bg-white rounded-xl flex items-center justify-center shadow-lg">
                <img src="LOGO-ADES_HD.png" alt="Logo ADES" />
                <div className="absolute -bottom-1 -right-1 w-4 h-4 bg-[#FFCC00] rounded-full border-2 border-white"></div>
              </div>
              <div>
                <h1 className="text-2xl font-bold text-white">Lemadio Admin</h1>
                <p className="text-xs text-white/90 font-medium">
                  Tableau de bord
                </p>
              </div>
            </div>
          </div>

          <div className="flex items-center space-x-4">
            {/* Badge Utilisateur */}
            <div className="hidden sm:flex items-center space-x-2 px-4 py-2 bg-white/20 backdrop-blur-sm rounded-full border border-white/40">
              <User size={16} className="text-white" />
              <span className="text-sm font-semibold text-white">
                {username}
              </span>
            </div>

            {/* Badge système */}
            <div className="hidden sm:flex items-center space-x-2 px-4 py-2 bg-white/20 backdrop-blur-sm rounded-full border border-white/40">
              <div className="w-2.5 h-2.5 bg-[#FFCC00] rounded-full animate-pulse"></div>
              <span className="text-sm font-semibold text-white">En ligne</span>
            </div>

            {/* Bouton Déconnexion */}
            {/* <button
              onClick={handleLogout}
              className="hidden sm:flex items-center gap-2 px-4 py-2 bg-red-500 hover:bg-red-600 text-white rounded-full transition-all font-semibold text-sm"
            >
              <LogOut size={16} />
              <span>Déconnexion</span>
            </button> */}
          </div>
        </div>
      </header>

      <div className="flex">
        {/* Sidebar Desktop */}
        <aside className="hidden lg:flex lg:flex-col lg:w-72 lg:bg-white lg:shadow-xl lg:h-[calc(100vh-73px)] border-r border-gray-200">
          {/* User Card */}
          <div className="p-6 bg-gradient-to-br from-[#4B8A34]/5 to-[#FFCC00]/5 border-b border-gray-200">
            <div className="flex items-center space-x-3">
              <div className="w-12 h-12 bg-gradient-to-br from-[#4B8A34] to-[#5a9d40] rounded-full flex items-center justify-center shadow-md ring-2 ring-[#FFCC00]/50">
                <span className="text-white font-bold text-lg">
                  {username.charAt(0).toUpperCase()}
                </span>
              </div>
              <div>
                <p className="font-semibold text-gray-900">{username}</p>
                <p className="text-sm text-gray-600">Administrateur</p>
              </div>
            </div>
          </div>

          {/* Navigation */}
          <nav className="flex-1 px-4 py-6 space-y-2">
            {navigation.map((item) => {
              const Icon = item.icon;
              const active = isActive(item.href);
              return (
                <Link
                  key={item.name}
                  to={item.href}
                  className={`w-full flex items-center px-4 py-3.5 text-sm font-semibold rounded-xl transition-all ${
                    active
                      ? "bg-gradient-to-r from-[#4B8A34] to-[#5a9d40] text-white shadow-lg"
                      : "text-gray-700 hover:bg-gradient-to-r hover:from-[#4B8A34]/10 hover:to-[#FFCC00]/10 hover:text-[#4B8A34]"
                  }`}
                >
                  <Icon
                    size={20}
                    className={`mr-3 ${active ? "" : "opacity-70"}`}
                  />
                  {item.name}
                  {active && (
                    <div className="ml-auto w-2 h-2 bg-[#FFCC00] rounded-full"></div>
                  )}
                </Link>
              );
            })}
          </nav>

          {/* Logout Button (Desktop) */}
          <div className="p-4 border-t border-gray-200">
            <button
              onClick={handleLogout}
              className="w-full flex items-center justify-center gap-2 px-4 py-3 bg-red-500 hover:bg-red-600 text-white rounded-xl transition-all font-semibold"
            >
              <LogOut size={18} />
              Déconnexion
            </button>
          </div>
        </aside>

        {/* Sidebar Mobile */}
        {sidebarOpen && (
          <div
            className="lg:hidden fixed inset-0 z-50 bg-black/60 backdrop-blur-sm"
            onClick={() => setSidebarOpen(false)}
          >
            <aside
              className="fixed inset-y-0 left-0 w-72 bg-white shadow-2xl"
              onClick={(e) => e.stopPropagation()}
            >
              <div className="px-6 py-4 bg-gradient-to-r from-[#4B8A34] to-[#5a9d40] flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  <div className="w-10 h-10 bg-white rounded-lg flex items-center justify-center">
                    <Leaf size={20} className="text-[#4B8A34]" />
                  </div>
                  <h2 className="text-lg font-bold text-white">Menu</h2>
                </div>
                <button
                  onClick={() => setSidebarOpen(false)}
                  className="p-2 rounded-lg text-white hover:bg-white/20"
                >
                  <X size={20} />
                </button>
              </div>

              {/* User Info Mobile */}
              <div className="p-6 bg-gradient-to-br from-[#4B8A34]/5 to-[#FFCC00]/5 border-b">
                <div className="flex items-center space-x-3">
                  <div className="w-12 h-12 bg-gradient-to-br from-[#4B8A34] to-[#5a9d40] rounded-full flex items-center justify-center">
                    <span className="text-white font-bold text-lg">
                      {username.charAt(0).toUpperCase()}
                    </span>
                  </div>
                  <div>
                    <p className="font-semibold text-gray-900">{username}</p>
                    <p className="text-sm text-gray-600">Administrateur</p>
                  </div>
                </div>
              </div>

              {/* Navigation Mobile */}
              <nav className="px-4 py-6 space-y-2">
                {navigation.map((item) => {
                  const Icon = item.icon;
                  const active = isActive(item.href);
                  return (
                    <Link
                      key={item.name}
                      to={item.href}
                      onClick={() => setSidebarOpen(false)}
                      className={`w-full flex items-center px-4 py-3.5 text-sm font-semibold rounded-xl transition-all ${
                        active
                          ? "bg-gradient-to-r from-[#4B8A34] to-[#5a9d40] text-white shadow-lg"
                          : "text-gray-700 hover:bg-gradient-to-r hover:from-[#4B8A34]/10 hover:to-[#FFCC00]/10 hover:text-[#4B8A34]"
                      }`}
                    >
                      <Icon
                        size={20}
                        className={`mr-3 ${active ? "" : "opacity-70"}`}
                      />
                      {item.name}
                    </Link>
                  );
                })}
              </nav>

              {/* Logout Mobile */}
              <div className="absolute bottom-0 left-0 right-0 p-4 border-t">
                <button
                  onClick={handleLogout}
                  className="w-full flex items-center justify-center gap-2 px-4 py-3 bg-red-500 hover:bg-red-600 text-white rounded-xl font-semibold"
                >
                  <LogOut size={18} />
                  Déconnexion
                </button>
              </div>
            </aside>
          </div>
        )}

        {/* Main Content */}
        <main className="flex-1 lg:h-[calc(100vh-73px)] overflow-hidden">
          {children}
        </main>
      </div>
    </div>
  );
};

export default Layout;
