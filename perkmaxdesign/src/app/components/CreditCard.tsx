import React from 'react';
import { motion } from 'motion/react';
import { Shield, Lock, Info, Sparkles } from 'lucide-react';
import { Card } from '../types';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

interface CreditCardProps {
  card: Card;
  variant?: 'list' | 'carousel' | 'mini';
  index?: number;
  onClick?: () => void;
  isExpanded?: boolean;
}

export const CreditCard: React.FC<CreditCardProps> = ({
  card,
  variant = 'list',
  index = 0,
  onClick,
  isExpanded = false
}) => {
  const isDark = ['#000000', '#2C3E50', '#004D40', '#114499'].includes(card.color);

  const getBankGradient = (color: string) => {
    if (card.bank === 'Chase') return `linear-gradient(135deg, ${color} 0%, #0a2e6e 100%)`;
    if (card.bank === 'American Express') return `linear-gradient(135deg, ${color} 0%, #b8932d 100%)`;
    if (card.bank === 'Apple Card') return `linear-gradient(135deg, #f5f5f7 0%, #d2d2d7 100%)`;
    return `linear-gradient(135deg, ${color} 0%, rgba(0,0,0,0.2) 100%)`;
  };

  return (
    <motion.div
      layout
      initial={{ opacity: 0, y: 20, rotateX: 5 }}
      animate={{ opacity: 1, y: 0, rotateX: 0 }}
      whileHover={{
        scale: 1.02,
        rotateY: 2,
        rotateX: -2,
        z: 10
      }}
      whileTap={{ scale: 0.98 }}
      onClick={onClick}
      style={{ perspective: '1000px' }}
      className={cn(
        "relative cursor-pointer transition-all duration-500",
        variant === 'list' && "mb-[-80px] hover:mb-[-60px]", // Overlapping stack effect
        isExpanded && "mb-4 hover:mb-4"
      )}
    >
      <div
        className={cn(
          "relative overflow-hidden transition-all duration-500",
          "rounded-xl border", // Standard Physical Card Radius
          isDark ? "text-white border-white/10 shadow-2xl shadow-black/20" : "text-slate-900 border-gray-200 shadow-xl shadow-gray-200/50",
          variant === 'carousel' ? "w-[300px] h-[190px]" : "w-full h-[200px]"
        )}
        style={{
          background: getBankGradient(card.color),
        }}
      >
        {/* Subtle Inner Glow & Texture */}
        <div className="absolute inset-0 bg-[url('https://www.transparenttextures.com/patterns/carbon-fibre.png')] opacity-[0.03] pointer-events-none" />
        <div className="absolute -top-20 -left-20 w-64 h-64 bg-white/5 rounded-full blur-3xl" />

        {/* Card Content */}
        <div className="p-6 h-full flex flex-col justify-between relative z-10">
          <div className="flex justify-between items-start">
            <div className="flex flex-col gap-1">
              <span className={cn(
                "text-[10px] uppercase tracking-[0.2em] font-sans font-bold opacity-60",
                !isDark && "text-slate-400"
              )}>
                {card.bank}
              </span>
              <h3 className="text-lg font-serif italic tracking-tight">{card.name}</h3>
            </div>
            <div className="flex items-center gap-2">
              {card.annualFee && card.annualFee > 0 && (
                <div className="bg-accent/20 backdrop-blur-md px-2 py-0.5 rounded-full border border-accent/30">
                  <span className="text-[8px] font-bold text-accent uppercase tracking-wider">${card.annualFee} FEE</span>
                </div>
              )}
              {card.isHighConfidence && (
                <div className="bg-green-500/20 backdrop-blur-md p-1 rounded-full border border-green-500/30">
                  <Sparkles size={10} className="text-green-400" />
                </div>
              )}
            </div>
          </div>

          <div className="flex justify-between items-end">
            <div>
              <div className="flex items-center gap-3 mb-1">
                <span className="text-xl font-sans tracking-[0.25em] font-medium opacity-90">
                  •••• {card.last4}
                </span>
              </div>
              <div className="flex items-center gap-2 opacity-40">
                <Lock size={10} />
                <span className="text-[9px] font-sans uppercase tracking-widest">No PAN Stored</span>
              </div>
            </div>

            <div className="flex flex-col items-end gap-2">
              <div className={cn(
                "w-10 h-6 rounded-md flex items-center justify-center text-[8px] font-black italic tracking-tighter shadow-sm",
                isDark ? "bg-white/10 border border-white/20" : "bg-slate-900/5 border border-slate-900/10"
              )}>
                {card.type.toUpperCase()}
              </div>
              {card.activationDate && (
                <span className="text-[8px] opacity-40 font-sans">SINCE {card.activationDate}</span>
              )}
            </div>
          </div>
        </div>

        {/* High Confidence Glow Border */}
        {card.isHighConfidence && (
          <div className="absolute inset-0 border-2 border-accent/30 rounded-[32px] rounded-tr-[12px] rounded-bl-[12px] pointer-events-none shadow-[inset_0_0_20px_rgba(212,175,55,0.1)]" />
        )}
      </div>
    </motion.div>
  );
};
