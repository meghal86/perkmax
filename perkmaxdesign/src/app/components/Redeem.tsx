import React from 'react';
import { Gift, Plane, Hotel, ShoppingBag, ArrowRight } from 'lucide-react';
import { motion } from 'motion/react';

const partners = [
  { id: '1', name: 'United Airlines', value: '1.4¢/pt', type: 'Flight', icon: <Plane size={20} /> },
  { id: '2', name: 'Hyatt Hotels', value: '2.1¢/pt', type: 'Hotel', icon: <Hotel size={20} /> },
  { id: '3', name: 'Delta Air Lines', value: '1.2¢/pt', type: 'Flight', icon: <Plane size={20} /> },
  { id: '4', name: 'Apple Store', value: '1.0¢/pt', type: 'Shopping', icon: <ShoppingBag size={20} /> },
];

export const Redeem: React.FC = () => {
  return (
    <div className="pb-32 pt-6 px-6 max-w-md mx-auto">
      <header className="mb-8">
        <h1 className="text-3xl text-primary font-bold">Redeem</h1>
        <p className="text-slate-500 font-sans text-sm">Best value for your points</p>
      </header>

      {/* Point Balance Card */}
      <div className="bg-[#2C3E50] p-8 rounded-[40px] text-white mb-10 relative overflow-hidden">
         <div className="absolute top-0 right-0 p-8 opacity-10 rotate-12">
            <Gift size={160} />
         </div>
         <p className="text-accent text-[10px] uppercase tracking-[0.2em] font-sans mb-2">Total Points Balance</p>
         <h2 className="text-4xl font-serif italic mb-6">142,500</h2>
         
         <div className="flex gap-10">
            <div>
               <p className="text-white/40 text-[10px] uppercase tracking-widest mb-1">Cash Value</p>
               <p className="text-xl font-bold font-sans">$2,992.50</p>
            </div>
            <div>
               <p className="text-white/40 text-[10px] uppercase tracking-widest mb-1">Potential</p>
               <p className="text-xl font-bold font-sans text-accent">+$420.00</p>
            </div>
         </div>
      </div>

      {/* Categories */}
      <div className="grid grid-cols-4 gap-4 mb-10">
         {[
           { icon: <Plane />, label: 'Flights' },
           { icon: <Hotel />, label: 'Hotels' },
           { icon: <ShoppingBag />, label: 'Retail' },
           { icon: <Gift />, label: 'Gift Cards' },
         ].map((cat, i) => (
           <div key={i} className="flex flex-col items-center gap-2">
              <div className="w-14 h-14 rounded-2xl bg-white shadow-sm border border-gray-100 flex items-center justify-center text-primary">
                 {cat.icon}
              </div>
              <span className="text-[10px] font-bold text-slate-500 uppercase tracking-tighter">{cat.label}</span>
           </div>
         ))}
      </div>

      {/* Partners List */}
      <div>
         <div className="flex justify-between items-center mb-6">
            <h4 className="text-lg text-primary">High Value Partners</h4>
            <span className="text-xs font-bold text-accent uppercase tracking-widest">See All</span>
         </div>
         <div className="space-y-4">
            {partners.map((partner, i) => (
              <motion.div
                key={partner.id}
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: i * 0.1 }}
                className="bg-white p-5 rounded-2xl border border-gray-100 flex justify-between items-center shadow-sm group hover:shadow-md transition-shadow cursor-pointer"
              >
                 <div className="flex items-center gap-4">
                    <div className="w-12 h-12 rounded-xl bg-primary/5 flex items-center justify-center text-primary group-hover:bg-primary group-hover:text-white transition-colors">
                       {partner.icon}
                    </div>
                    <div>
                       <p className="font-serif font-bold text-slate-800 tracking-tight">{partner.name}</p>
                       <p className="text-xs text-slate-400 font-sans">{partner.type}</p>
                    </div>
                 </div>
                 <div className="text-right flex items-center gap-3">
                    <div>
                       <p className="text-sm font-bold text-primary font-sans">{partner.value}</p>
                       <p className="text-[9px] text-slate-400 font-sans uppercase tracking-widest">Yield</p>
                    </div>
                    <ArrowRight size={16} className="text-slate-300 group-hover:text-primary transition-colors" />
                 </div>
              </motion.div>
            ))}
         </div>
      </div>
    </div>
  );
};
