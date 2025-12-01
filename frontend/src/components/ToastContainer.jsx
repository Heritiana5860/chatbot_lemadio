import Toast from "./Toast";

const ToastContainer = ({ toasts, onRemove }) => (
  <div className="fixed top-4 right-4 z-50 space-y-3 max-w-md">
    {toasts.map((toast) => (
      <Toast key={toast.id} {...toast} onClose={() => onRemove(toast.id)} />
    ))}
  </div>
);

export default ToastContainer;
