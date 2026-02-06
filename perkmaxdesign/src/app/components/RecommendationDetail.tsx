import React from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { X, Info, ShieldCheck, TrendingUp, HelpCircle, ArrowLeft, CheckCircle2 } from 'lucide-react';
import { Recommendation } from '../types';
import { toast } from 'sonner';

interface RecommendationDetailProps {
  rec: Recommendation | null;
  onClose: () => void;
}

export const RecommendationDetail: React.FC<RecommendationDetailProps> = ({ rec, onClose }) => {
  if (!rec) return null;

  const handleConfirm = () => {
    toast.success(`Strategy Confirmed!`, {
      description: `Using ${rec.card.name} for ${rec.merchantName}. Rewards tracked.`,
      icon: <CheckCircle2 className="text-green-500" size={16} />
    });
    onClose();
  };

  const handleOverride = () => {
    toast.info("Selecting Override", {
      description: "Redirecting to full card list for manual selection..."
    });
  };

  return (
    <motion.div
      initial={{ y: '100%' }}
      animate={{ y: 0 }}
      exit={{ y: '100%' }}
      transition={{ type: 'spring', damping: 25, stiffness: 200 }}
      className="fixed inset-0 bg-white z-[60] overflow-y-auto"
    >
      <div className="max-w-md mx-auto min-h-full pb-10">
        {/* Top Bar */}
        <div className="sticky top-0 bg-white/80 backdrop-blur-md px-6 py-6 flex justify-between items-center z-10">
          <button 
            onClick={onClose}
            className="w-10 h-10 rounded-full bg-gray-50 flex items-center justify-center text-slate-400"
          >
            <ArrowLeft size={20} />
          </button>
          <h2 className="text-xl font-bold text-primary">Card Advisory</h2>
          <div className="w-10" />
        </div>

        <div className="px-6 pt-4">
          {/* Hero Card Summary */}
          <div className="bg-primary p-8 rounded-[32px] mb-8 text-white relative overflow-hidden">
             <div className="absolute top-0 right-0 p-4 opacity-10">
                <ShieldCheck size={120} />
             </div>
             <p className="text-accent text-sm font-sans mb-1">Optimized for {rec.merchantName}</p>
             <h3 className="text-2xl mb-6 leading-tight">{rec.card.name}</h3>
             
             <div className="flex gap-10 items-end">
                <div>
                   <p className="text-white/40 text-[10px] uppercase tracking-widest mb-1">Rewards</p>
                   <p className="text-3xl font-bold font-serif italic text-accent">{rec.pointsMultiplier}x</p>
                </div>
                <div>
                   <p className="text-white/40 text-[10px] uppercase tracking-widest mb-1">Est. Value</p>
                   <p className="text-3xl font-bold font-serif italic">${rec.savedAmount.toFixed(2)}</p>
                </div>
             </div>
          </div>

          {/* Explainability Section */}
          <section className="mb-10">
            <div className="flex items-center gap-2 mb-4">
              <h4 className="text-lg text-primary">Why this recommendation?</h4>
              <Info size={16} className="text-slate-300" />
            </div>
            
            <div className="space-y-6">
              {/* Confidence Band - Custom textured arc */}
              <div className="bg-gray-50 p-6 rounded-3xl border border-gray-100">
                <div className="flex justify-between items-center mb-4">
                  <p className="text-sm font-bold text-slate-700 font-sans tracking-tight">Confidence Level</p>
                  <span className="text-green-600 font-bold text-xs uppercase tracking-widest">High</span>
                </div>
                
                {/* Custom SVG Arc for Confidence */}
                <div className="relative h-24 flex items-center justify-center mb-4">
                  <svg viewBox="0 0 100 50" className="w-48 h-24">
                    <path
                      d="M 10 45 A 35 35 0 0 1 90 45"
                      fill="none"
                      stroke="#E5E7EB"
                      strokeWidth="8"
                      strokeLinecap="round"
                    />
                    <motion.path
                      initial={{ pathLength: 0 }}
                      animate={{ pathLength: 0.85 }}
                      transition={{ duration: 1.5, ease: "easeOut" }}
                      d="M 10 45 A 35 35 0 0 1 90 45"
                      fill="none"
                      stroke="#004D40"
                      strokeWidth="8"
                      strokeLinecap="round"
                      strokeDasharray="100 100"
                    />
                  </svg>
                  <div className="absolute inset-0 flex flex-col items-center justify-end pb-2">
                    <span className="text-2xl font-bold text-primary font-serif italic">85%</span>
                    <span className="text-[8px] text-slate-400 font-sans uppercase tracking-[0.2em]">Match Rate</span>
                  </div>
                </div>
                
                <p className="text-sm text-slate-500 font-sans leading-relaxed italic">
                  "Based on your last 3 visits to Best Buy and current Chase quarterly offers, this card maximizes your 5% electronics category."
                </p>
              </div>

              {/* Reward Breakdown */}
              <div className="grid grid-cols-1 gap-4">
                <div className="flex items-start gap-4 p-4 bg-white rounded-2xl border border-gray-100 shadow-sm">
                  <div className="w-10 h-10 rounded-xl bg-accent/10 flex items-center justify-center text-accent shrink-0">
                    <TrendingUp size={20} />
                  </div>
                  <div>
                    <p className="text-sm font-bold text-slate-800 font-serif">Category Bonus</p>
                    <p className="text-xs text-slate-500 font-sans">3% base on all electronic retailers</p>
                  </div>
                </div>
                <div className="flex items-start gap-4 p-4 bg-white rounded-2xl border border-gray-100 shadow-sm">
                  <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center text-primary shrink-0">
                    <ShieldCheck size={20} />
                  </div>
                  <div>
                    <p className="text-sm font-bold text-slate-800 font-serif">Purchase Protection</p>
                    <p className="text-xs text-slate-500 font-sans">Includes 1-year extended warranty</p>
                  </div>
                </div>
              </div>
            </div>
          </section>

          {/* Override Action */}
          <div className="space-y-4">
            <button 
              onClick={handleConfirm}
              className="w-full bg-primary text-white py-5 rounded-2xl font-sans font-bold shadow-xl shadow-primary/10 active:scale-95 transition-transform"
            >
              Confirm Using This Card
            </button>
            <button 
              onClick={handleOverride}
              className="w-full bg-white text-slate-400 py-4 rounded-2xl font-sans font-medium border border-gray-100 flex items-center justify-center gap-2"
            >
              <HelpCircle size={16} />
              Override Recommendation
            </button>
          </div>
          
          <p className="text-center text-[10px] text-slate-300 font-sans mt-8 uppercase tracking-widest">
            Advisory only • No PAN stored • Encrypted by PerkMax
          </p>
        </div>
      </div>
    </motion.div>
  );
};
