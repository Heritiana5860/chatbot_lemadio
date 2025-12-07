import { useContext, createContext,} from "react";

export const ChatContext = createContext(null);

export const useChatContext = () => {
  const context = useContext(ChatContext);
  if (!context) {
    throw new Error("useChatContext doit être utilisé dans un ChatProvider");
  }
  return context;
};

export const welcomeMessage = {
  id: 1,
  type: "assistant",
  content:
    "Bonjour ! Je suis votre assistant de formation Lemadio. Posez-moi vos questions sur l'utilisation de l'application et je vous guiderai avec plaisir !",
  timestamp: new Date(),
};