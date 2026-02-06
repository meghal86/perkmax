import React, { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { MessageSquare, X, Send, Sparkles, Bot, User } from 'lucide-react';
import { toast } from 'sonner';

interface Message {
  id: string;
  text: string;
  sender: 'user' | 'bot';
  timestamp: Date;
}

interface ChatBotProps {
  isOpen: boolean;
  setIsOpen: (open: boolean) => void;
}

export const ChatBot: React.FC<ChatBotProps> = ({ isOpen, setIsOpen }) => {
  const [messages, setMessages] = useState<Message[]>([
    {
      id: '1',
      text: "Hello! I'm your PerkMax Advisor. Ask me anything about your cards, rewards, or spending strategy.",
      sender: 'bot',
      timestamp: new Date()
    }
  ]);
  const [input, setInput] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages, isTyping]);

  const handleSend = () => {
    if (!input.trim()) return;

    const userMsg: Message = {
      id: Date.now().toString(),
      text: input,
      sender: 'user',
      timestamp: new Date()
    };

    setMessages(prev => [...prev, userMsg]);
    setInput('');
    setIsTyping(true);

    // Simulate AI Response
    setTimeout(() => {
      const response = getAIResponse(input);
      const botMsg: Message = {
        id: (Date.now() + 1).toString(),
        text: response,
        sender: 'bot',
        timestamp: new Date()
      };
      setMessages(prev => [...prev, botMsg]);
      setIsTyping(false);
    }, 1500);
  };

  const getAIResponse = (query: string) => {
    const q = query.toLowerCase();
    if (q.includes('chase')) return "Your Chase Freedom Unlimited is currently earning 5% on travel and 3% on dining. Since you're at Starbucks, I recommend this card!";
    if (q.includes('amex')) return "The Amex Gold is best for groceries (4x). You've used 65% of your annual dining credit so far this year.";
    if (q.includes('fee')) return "You're paying $790 in total annual fees across 5 cards. However, your rewards value last year was $2,420, giving you a net profit of $1,630.";
    if (q.includes('best') || q.includes('recommend')) return "For general spending, your Apple Card is best for 2% back via Apple Pay. For travel, use the Amex Platinum for 5x points.";
    return "That's a great question. Based on your spending patterns, you could increase your rewards by 12% by switching your primary grocery card to the Amex Gold.";
  };

  return (
    <>
      {/* Floating Toggle Button */}
      <motion.button
        whileHover={{ scale: 1.1 }}
        whileTap={{ scale: 0.9 }}
        onClick={() => setIsOpen(!isOpen)}
        className="fixed bottom-24 left-6 w-14 h-14 rounded-full bg-accent text-primary flex items-center justify-center shadow-2xl z-50 border-4 border-white"
      >
        {isOpen ? <X size={24} /> : <MessageSquare size={24} />}
      </motion.button>

      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ opacity: 0, scale: 0.9, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.9, y: 20 }}
            className="fixed inset-x-6 bottom-40 top-20 bg-white rounded-[40px] shadow-2xl z-50 flex flex-col overflow-hidden border border-gray-100 max-w-md mx-auto"
          >
            {/* Header */}
            <div className="bg-primary p-6 text-white flex justify-between items-center">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-accent flex items-center justify-center text-primary">
                  <Bot size={20} />
                </div>
                <div>
                  <h3 className="font-serif font-bold tracking-tight">PerkMax Advisor</h3>
                  <div className="flex items-center gap-1.5">
                    <div className="w-1.5 h-1.5 bg-green-400 rounded-full animate-pulse" />
                    <span className="text-[10px] uppercase tracking-widest opacity-60">AI Online</span>
                  </div>
                </div>
              </div>
              <button onClick={() => setIsOpen(false)} className="opacity-60 hover:opacity-100">
                <X size={20} />
              </button>
            </div>

            {/* Messages Area */}
            <div 
              ref={scrollRef}
              className="flex-1 overflow-y-auto p-6 space-y-4 no-scrollbar bg-gray-50/50"
            >
              {messages.map((msg) => (
                <motion.div
                  key={msg.id}
                  initial={{ opacity: 0, x: msg.sender === 'user' ? 20 : -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  className={`flex ${msg.sender === 'user' ? 'justify-end' : 'justify-start'}`}
                >
                  <div className={`max-w-[85%] p-4 rounded-3xl ${
                    msg.sender === 'user' 
                      ? 'bg-primary text-white rounded-tr-none' 
                      : 'bg-white text-slate-700 shadow-sm border border-gray-100 rounded-tl-none'
                  }`}>
                    <p className="text-sm font-sans leading-relaxed">{msg.text}</p>
                    <p className={`text-[8px] mt-2 opacity-40 uppercase tracking-tighter ${
                      msg.sender === 'user' ? 'text-right' : 'text-left'
                    }`}>
                      {msg.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                    </p>
                  </div>
                </motion.div>
              ))}
              {isTyping && (
                <div className="flex justify-start">
                  <div className="bg-white p-4 rounded-3xl shadow-sm border border-gray-100 rounded-tl-none flex gap-1">
                    <div className="w-1.5 h-1.5 bg-slate-300 rounded-full animate-bounce [animation-delay:-0.3s]" />
                    <div className="w-1.5 h-1.5 bg-slate-300 rounded-full animate-bounce [animation-delay:-0.15s]" />
                    <div className="w-1.5 h-1.5 bg-slate-300 rounded-full animate-bounce" />
                  </div>
                </div>
              )}
            </div>

            {/* Input Area */}
            <div className="p-6 bg-white border-t border-gray-100">
              <div className="flex gap-2">
                <input
                  type="text"
                  value={input}
                  onChange={(e) => setInput(e.target.value)}
                  onKeyPress={(e) => e.key === 'Enter' && handleSend()}
                  placeholder="Ask about rewards, fees, or best cards..."
                  className="flex-1 bg-gray-50 border-none rounded-2xl px-4 py-3 text-sm font-sans focus:ring-2 focus:ring-primary/10 transition-all outline-none"
                />
                <button
                  onClick={handleSend}
                  disabled={!input.trim()}
                  className="w-12 h-12 rounded-2xl bg-primary text-white flex items-center justify-center disabled:opacity-50 shadow-lg shadow-primary/20"
                >
                  <Send size={18} />
                </button>
              </div>
              <p className="text-[9px] text-center text-slate-300 mt-4 uppercase tracking-[0.2em]">
                <Sparkles size={8} className="inline mr-1" /> Powered by PerkMax Neural Engine
              </p>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
};
