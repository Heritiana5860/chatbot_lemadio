// components/ConfirmModal.jsx
import { motion, AnimatePresence } from "framer-motion";
import { AlertTriangle } from "lucide-react";

const ConfirmModal = ({ open, onClose, onConfirm, title, message }) => {
  return (
    <AnimatePresence>
      {open && (
        <motion.div
          className="fixed inset-0 bg-black/40 backdrop-blur-sm flex items-center justify-center z-50"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
        >
          <motion.div
            className="bg-white p-6 rounded-2xl shadow-xl w-full max-w-sm"
            initial={{ scale: 0.85, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            exit={{ scale: 0.85, opacity: 0 }}
          >
            <div className="flex items-center gap-3 mb-4">
              <AlertTriangle className="text-red-500" />
              <h2 className="text-lg font-semibold">{title}</h2>
            </div>

            <p className="text-gray-700 mb-6">{message}</p>

            <div className="flex justify-end gap-3">
              <button
                onClick={onClose}
                className="px-4 py-2 rounded-lg bg-gray-100 hover:bg-gray-200 transition"
              >
                Annuler
              </button>

              <button
                onClick={() => {
                  onConfirm();
                  onClose();
                }}
                className="px-4 py-2 rounded-lg bg-red-500 text-white hover:bg-red-600 transition"
              >
                Confirmer
              </button>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};

export default ConfirmModal;
