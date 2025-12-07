import { Navigate } from "react-router-dom";
import { isAuthenticated } from "../services/api";

/**
 * Composant pour protéger les routes admin
 */
const ProtectedRoute = ({ children }) => {
  if (!isAuthenticated()) {
    // Rediriger vers login si pas authentifié
    return <Navigate to="/login" replace />;
  }

  return children;
};

export default ProtectedRoute;
