import { CheckCircle, XCircle, AlertCircle, Info, X } from "lucide-react";

const config = {
  success: {
    icon: CheckCircle,
    bgColor: "from-green-500 to-green-600",
    borderColor: "border-green-600",
    textColor: "text-white",
  },
  error: {
    icon: XCircle,
    bgColor: "from-red-500 to-red-600",
    borderColor: "border-red-600",
    textColor: "text-white",
  },
  warning: {
    icon: AlertCircle,
    bgColor: "from-[#FFCC00] to-[#FFD633]",
    borderColor: "border-[#FFCC00]",
    textColor: "text-gray-900",
  },
  info: {
    icon: Info,
    bgColor: "from-blue-500 to-blue-600",
    borderColor: "border-blue-600",
    textColor: "text-white",
  },
};

const Toast = ({ message, type, onClose }) => {
  const { icon: Icon, bgColor, borderColor, textColor } = config[type];
  return (
    <div
      className={`flex items-start gap-3 p-4 rounded-xl shadow-2xl bg-gradient-to-r ${bgColor} border-2 ${borderColor} animate-slide-in-right backdrop-blur-sm ${textColor}`}
    >
      <Icon size={20} className="mt-0.5" />
      <p className="flex-1 text-sm font-semibold leading-relaxed">{message}</p>
      <button
        onClick={onClose}
        className="p-1 rounded-lg hover:bg-white/20 transition-colors"
      >
        <X size={16} />
      </button>
    </div>
  );
};

export default Toast;
