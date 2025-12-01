import React from "react";
import {
  BrowserRouter as Router,
  Routes,
  Route,
  Navigate,
} from "react-router-dom";
import Layout from "./components/Layout";
import ChatPage from "./pages/ChatPage";
import HistoryPage from "./pages/HistoryPage";
import DashboardPage from "./pages/DashboardPage";
import { ToastProvider } from "./components/ToastProvider";
import { ChatProvider } from "./contextes/ChatContext";

function App() {
  return (
    <ToastProvider>
      <ChatProvider>
        <Router>
          <Layout>
            <Routes>
              <Route path="/" element={<Navigate to="/chat" replace />} />
              <Route path="/chat" element={<ChatPage />} />
              <Route path="/history" element={<HistoryPage />} />
              <Route path="/dashboard" element={<DashboardPage />} />
            </Routes>
          </Layout>
        </Router>
      </ChatProvider>
    </ToastProvider>
  );
}

export default App;
