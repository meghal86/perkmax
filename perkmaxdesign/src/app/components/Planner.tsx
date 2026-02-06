import React from 'react';
import { Target, Flag, TrendingUp, ChevronRight, BarChart3, AlertCircle } from 'lucide-react';
import { motion } from 'motion/react';

export const Planner: React.FC = () => {
  return (
    <div className="pb-32 pt-6 px-6 max-w-md mx-auto">
      <header className="mb-8">
        <h1 className="text-3xl text-primary font-bold">Planner</h1>
        <p className="text-slate-500 font-sans text-sm">Strategic reward goals</p>
      </header>

      {/* Goal Cards */}
      <div className="space-y-6 mb-10">
        <div className="bg-white p-6 rounded-[32px] border border-gray-100 shadow-xl shadow-gray-200/40 relative overflow-hidden">
          <div className="flex justify-between items-start mb-6">
            <div className="w-12 h-12 rounded-2xl bg-accent/10 flex items-center justify-center text-accent">
              <Target size={24} />
            </div>
            <div className="text-right">
              <span className="text-xs font-bold text-accent bg-accent/5 px-2 py-1 rounded-lg uppercase tracking-widest">Active</span>
            </div>
          </div>
          
          <h3 className="text-xl font-serif text-slate-800 mb-2">Summer Trip to Tokyo</h3>
          <p className="text-xs text-slate-400 font-sans mb-6">Reach 200,000 points by June 2026</p>
          
          <div className="space-y-3">
             <div className="flex justify-between items-end mb-1">
                <span className="text-sm font-bold text-slate-700 font-sans">Progress</span>
                <span className="text-sm font-bold text-primary font-serif">142,500 / 200K</span>
             </div>
             <div className="h-2 w-full bg-gray-100 rounded-full overflow-hidden">
                <motion.div 
                  initial={{ width: 0 }}
                  animate={{ width: '71%' }}
                  transition={{ duration: 1.5, ease: "easeOut" }}
                  className="h-full bg-primary rounded-full"
                />
             </div>
             <p className="text-[10px] text-slate-400 font-sans italic text-right">Estimated completion: May 12</p>
          </div>
        </div>

        {/* Bonus Scenarios */}
        <div className="grid grid-cols-2 gap-4">
           <div className="bg-[#2C3E50] p-5 rounded-3xl text-white">
              <Flag size={20} className="text-accent mb-4" />
              <p className="text-[10px] text-white/50 uppercase tracking-widest mb-1">Bonus Target</p>
              <p className="text-lg font-serif leading-tight">Hit $5K spend bonus</p>
              <div className="mt-4 pt-4 border-t border-white/10 flex justify-between items-center">
                 <span className="text-xs font-bold">$1.2K left</span>
                 <ChevronRight size={14} className="text-white/20" />
              </div>
           </div>
           <div className="bg-white p-5 rounded-3xl border border-gray-100 shadow-sm">
              <BarChart3 size={20} className="text-primary mb-4" />
              <p className="text-[10px] text-slate-400 uppercase tracking-widest mb-1">Value At Risk</p>
              <p className="text-lg font-serif text-primary leading-tight">Protect $1.4K travel</p>
              <div className="mt-4 pt-4 border-t border-gray-50 flex justify-between items-center">
                 <span className="text-xs font-bold text-slate-600">High Risk</span>
                 <AlertCircle size={14} className="text-red-400" />
              </div>
           </div>
        </div>
      </div>

      {/* Advisory Insight */}
      <section>
         <h4 className="text-lg text-primary mb-4">Strategic Insights</h4>
         <div className="space-y-4">
            <div className="bg-primary/5 p-5 rounded-2xl border border-primary/10 flex gap-4 items-start">
               <div className="w-8 h-8 rounded-full bg-primary flex items-center justify-center text-white shrink-0 mt-1">
                  <TrendingUp size={16} />
               </div>
               <div>
                  <p className="text-sm font-bold text-primary font-serif">Maximize Chase Kicker</p>
                  <p className="text-xs text-slate-500 font-sans leading-relaxed mt-1">
                    Your electronics spending is 12% higher than average. Consider the Amazon Prime card for better returns next month.
                  </p>
               </div>
            </div>
         </div>
      </section>
    </div>
  );
};
