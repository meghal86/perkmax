import React from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { X, Trash2, Edit3, Shield, Info, ExternalLink } from 'lucide-react';
import { Card } from '../types';
import { toast } from 'sonner';

interface CardEditDrawerProps {
  card: Card | null;
  onClose: () => void;
  onDelete: (id: string) => void;
}

export const CardEditDrawer: React.FC<CardEditDrawerProps> = ({ card, onClose, onDelete }) => {
  if (!card) return null;

  const handleEdit = () => {
    toast.success(`Opening editor for ${card.name}`, {
      description: "You can update last-4, annual fee, and nicknames."
    });
  };

  const handleBenefits = () => {
    toast.info(`Fetching benefits for ${card.bank}`, {
      description: "Loading full rewards guide and purchase protection details..."
    });
  };

  return (
    <>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        onClick={onClose}
        className="fixed inset-0 bg-black/40 backdrop-blur-sm z-[70]"
      />
      <motion.div
        initial={{ y: '100%' }}
        animate={{ y: 0 }}
        exit={{ y: '100%' }}
        transition={{ type: 'spring', damping: 25, stiffness: 200 }}
        className="fixed bottom-0 left-0 right-0 bg-white rounded-t-[40px] z-[80] px-8 pt-10 pb-12 max-w-md mx-auto"
      >
        <div className="w-12 h-1.5 bg-gray-100 rounded-full mx-auto mb-8" />
        
        <header className="flex justify-between items-start mb-8">
          <div>
            <h2 className="text-2xl font-serif text-primary mb-1">{card.name}</h2>
            <p className="text-slate-400 font-sans text-sm">Managed by PerkMax Advisor</p>
          </div>
          <button 
            onClick={onClose}
            className="w-10 h-10 rounded-full bg-gray-50 flex items-center justify-center text-slate-400"
          >
            <X size={20} />
          </button>
        </header>

        <div className="space-y-6">
          <div className="grid grid-cols-2 gap-4">
             <div className="bg-gray-50 p-4 rounded-2xl">
                <p className="text-[10px] text-slate-400 uppercase tracking-widest mb-1">Last 4 Digits</p>
                <p className="font-sans font-bold text-slate-700 tracking-widest">•••• {card.last4}</p>
             </div>
             <div className="bg-gray-50 p-4 rounded-2xl">
                <p className="text-[10px] text-slate-400 uppercase tracking-widest mb-1">Annual Fee</p>
                <p className="font-sans font-bold text-slate-700">${card.annualFee || 0}</p>
             </div>
          </div>

          <div className="bg-primary/5 p-5 rounded-3xl border border-primary/10 flex gap-4 items-start">
            <div className="w-10 h-10 rounded-full bg-primary flex items-center justify-center text-white shrink-0">
               <Shield size={20} />
            </div>
            <div>
               <p className="text-sm font-bold text-primary font-serif">Encrypted Storage</p>
               <p className="text-xs text-slate-500 font-sans leading-relaxed mt-1">
                 PerkMax only stores the last 4 digits and issuer metadata. Your actual payment info is never touched.
               </p>
            </div>
          </div>

          <div className="space-y-3 pt-4">
            <button 
              onClick={handleEdit}
              className="w-full bg-white border border-gray-100 py-4 rounded-2xl font-sans font-bold flex items-center justify-center gap-2 hover:bg-gray-50 transition-colors"
            >
              <Edit3 size={18} /> Edit Card Details
            </button>
            <button 
              onClick={handleBenefits}
              className="w-full bg-white border border-gray-100 py-4 rounded-2xl font-sans font-bold flex items-center justify-center gap-2 hover:bg-gray-50 transition-colors"
            >
              <ExternalLink size={18} /> View Benefits Guide
            </button>
            <button 
              onClick={() => {
                toast.error(`${card.name} removed`, {
                  description: "This card will no longer be used for recommendations."
                });
                onDelete(card.id);
                onClose();
              }}
              className="w-full bg-red-50 text-red-600 py-4 rounded-2xl font-sans font-bold flex items-center justify-center gap-2"
            >
              <Trash2 size={18} /> Remove from Wallet
            </button>
          </div>
        </div>
      </motion.div>
    </>
  );
};
