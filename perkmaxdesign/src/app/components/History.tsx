import React, { useState } from 'react';
import { Search, Filter, ArrowUpRight, Calendar, Tag, X, Receipt, MapPin, CreditCard } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { toast } from 'sonner';

const historyItems = [
  { id: '1', merchant: 'Best Buy', date: 'Feb 5, 2026', card: 'Chase Freedom', saved: 52.50, category: 'Electronics', points: 1575 },
  { id: '2', merchant: 'Starbucks', date: 'Feb 5, 2026', card: 'Amex Gold', saved: 1.40, category: 'Dining', points: 42 },
  { id: '3', merchant: 'Delta Air Lines', date: 'Feb 3, 2026', card: 'Amex Gold', saved: 124.00, category: 'Travel', points: 3720 },
  { id: '4', merchant: 'Amazon', date: 'Feb 1, 2026', card: 'Apple Card', saved: 12.20, category: 'Shopping', points: 366 },
  { id: '5', merchant: 'Whole Foods', date: 'Jan 28, 2026', card: 'Chase Freedom', saved: 8.90, category: 'Groceries', points: 267 },
];

export const History: React.FC = () => {
  const [selectedTransaction, setSelectedTransaction] = useState<typeof historyItems[0] | null>(null);

  const handleDetailsClick = (item: typeof historyItems[0]) => {
    setSelectedTransaction(item);
  };

  return (
    <div className="pb-32 pt-6 px-6 max-w-md mx-auto">
      <header className="mb-8">
        <h1 className="text-3xl text-primary font-bold">History</h1>
        <p className="text-slate-500 font-sans text-sm">You've saved $428.12 this month</p>
      </header>

      {/* Search & Filter */}
      <div className="flex gap-3 mb-8">
        <div className="relative flex-1">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
          <input 
            type="text" 
            placeholder="Search merchants..." 
            className="w-full bg-white py-3 pl-11 pr-4 rounded-2xl border-none shadow-sm font-sans text-sm focus:ring-2 focus:ring-primary/10 transition-all outline-none"
          />
        </div>
        <button className="w-12 h-12 rounded-2xl bg-white border border-gray-100 flex items-center justify-center text-slate-400 shadow-sm">
          <Filter size={18} />
        </button>
      </div>

      {/* Aggregate Stats */}
      <div className="bg-primary p-6 rounded-[32px] mb-8 text-white flex justify-between items-center overflow-hidden relative">
         <div className="absolute top-0 right-0 w-32 h-32 bg-accent/10 rounded-full -mr-10 -mt-10 blur-2xl" />
         <div>
            <p className="text-white/40 text-[10px] uppercase tracking-widest mb-1 font-sans">Avg. Per Transaction</p>
            <p className="text-3xl font-bold font-serif italic text-accent">$4.20</p>
         </div>
         <div className="text-right">
            <p className="text-white/40 text-[10px] uppercase tracking-widest mb-1 font-sans">Points Earned</p>
            <p className="text-xl font-bold font-sans">12.4K</p>
         </div>
      </div>

      {/* List */}
      <div className="space-y-4">
        {historyItems.map((item, i) => (
          <motion.div
            key={item.id}
            initial={{ y: 10, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: i * 0.05 }}
            onClick={() => handleDetailsClick(item)}
            className="bg-white p-5 rounded-2xl border border-gray-100 shadow-sm group hover:border-primary/20 transition-colors cursor-pointer"
          >
            <div className="flex justify-between items-start mb-4">
              <div className="flex gap-4">
                <div className="w-12 h-12 rounded-xl bg-gray-50 flex items-center justify-center text-xl">
                  {item.category === 'Dining' ? '☕' : item.category === 'Electronics' ? '💻' : item.category === 'Travel' ? '✈️' : '📦'}
                </div>
                <div>
                  <h4 className="font-serif font-bold text-slate-800 tracking-tight text-base leading-tight">{item.merchant}</h4>
                  <div className="flex items-center gap-2 mt-1">
                    <span className="text-[10px] text-slate-400 font-sans flex items-center gap-1">
                      <Calendar size={10} /> {item.date}
                    </span>
                    <span className="text-[10px] text-slate-400 font-sans flex items-center gap-1">
                      <Tag size={10} /> {item.category}
                    </span>
                  </div>
                </div>
              </div>
              <div className="text-right">
                <p className="text-green-600 font-bold font-sans tracking-tight">+${item.saved.toFixed(2)}</p>
                <p className="text-[9px] text-slate-400 font-sans uppercase tracking-widest">{item.card}</p>
              </div>
            </div>
            
            <div className="pt-3 border-t border-gray-50 flex justify-between items-center opacity-60 group-hover:opacity-100 transition-opacity">
               <span className="text-[10px] text-slate-400 italic">"HIGH Match" confirmation receipt</span>
               <button className="text-[10px] font-bold text-primary uppercase tracking-widest flex items-center gap-1">
                 Details <ArrowUpRight size={12} />
               </button>
            </div>
          </motion.div>
        ))}
      </div>

      {/* Transaction Detail Drawer */}
      <AnimatePresence>
        {selectedTransaction && (
          <>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setSelectedTransaction(null)}
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
                  <div className="flex items-center gap-2 mb-1">
                    <div className="w-8 h-8 rounded-lg bg-primary/5 flex items-center justify-center text-primary">
                      <Receipt size={16} />
                    </div>
                    <span className="text-[10px] text-slate-400 uppercase tracking-widest font-sans">Transaction Detail</span>
                  </div>
                  <h2 className="text-2xl font-serif text-primary">{selectedTransaction.merchant}</h2>
                </div>
                <button 
                  onClick={() => setSelectedTransaction(null)}
                  className="w-10 h-10 rounded-full bg-gray-50 flex items-center justify-center text-slate-400"
                >
                  <X size={20} />
                </button>
              </header>

              <div className="space-y-6">
                <div className="bg-gray-50 p-6 rounded-3xl flex flex-col items-center text-center">
                   <p className="text-[10px] text-slate-400 uppercase tracking-widest mb-2">Rewards Earned</p>
                   <p className="text-4xl font-serif italic text-primary font-bold mb-1">+${selectedTransaction.saved.toFixed(2)}</p>
                   <p className="text-xs text-accent font-bold uppercase tracking-wider">{selectedTransaction.points} Points Gained</p>
                </div>

                <div className="space-y-4">
                  <div className="flex items-center justify-between p-4 bg-white border border-gray-100 rounded-2xl">
                    <div className="flex items-center gap-3">
                      <Calendar size={18} className="text-slate-400" />
                      <span className="text-sm font-sans text-slate-600">Date</span>
                    </div>
                    <span className="text-sm font-bold text-slate-800">{selectedTransaction.date}</span>
                  </div>

                  <div className="flex items-center justify-between p-4 bg-white border border-gray-100 rounded-2xl">
                    <div className="flex items-center gap-3">
                      <CreditCard size={18} className="text-slate-400" />
                      <span className="text-sm font-sans text-slate-600">Card Used</span>
                    </div>
                    <span className="text-sm font-bold text-slate-800">{selectedTransaction.card}</span>
                  </div>

                  <div className="flex items-center justify-between p-4 bg-white border border-gray-100 rounded-2xl">
                    <div className="flex items-center gap-3">
                      <Tag size={18} className="text-slate-400" />
                      <span className="text-sm font-sans text-slate-600">Category</span>
                    </div>
                    <span className="text-sm font-bold text-slate-800">{selectedTransaction.category}</span>
                  </div>
                </div>

                <button 
                  onClick={() => {
                    toast.success("Receipt downloaded", { description: "Available in your device storage." });
                    setSelectedTransaction(null);
                  }}
                  className="w-full bg-primary text-white py-4 rounded-2xl font-sans font-bold shadow-lg shadow-primary/20"
                >
                  Download Receipt
                </button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </div>
  );
};
