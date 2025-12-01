import React, { useState, useCallback } from "react";
import { ToastContext } from "./ToastContext";
import ToastContainer from "./ToastContainer";

export const ToastProvider = ({ children }) => {
  const [toasts, setToasts] = useState([]);

  const removeToast = useCallback((id) => {
    setToasts((prev) => prev.filter((toast) => toast.id !== id));
  }, []);

  const addToast = useCallback(
    (message, type = "info", duration = 3000) => {
      const id = Date.now();
      setToasts((prev) => [...prev, { id, message, type }]);

      if (duration > 0) {
        setTimeout(() => removeToast(id), duration);
      }

      return id;
    },
    [removeToast]
  );

  const api = {
    success: (msg, dur) => addToast(msg, "success", dur),
    error: (msg, dur) => addToast(msg, "error", dur),
    warning: (msg, dur) => addToast(msg, "warning", dur),
    info: (msg, dur) => addToast(msg, "info", dur),
    removeToast,
  };

  return (
    <ToastContext.Provider value={api}>
      {children}
      <ToastContainer toasts={toasts} onRemove={removeToast} />
    </ToastContext.Provider>
  );
};
