import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import {
  Plus,
  Search,
  Filter,
  LayoutList,
  LayoutGrid,
  Download,
  Lock,
  ChevronRight,
  CreditCard as CardIcon
} from 'lucide-react';
import { Card } from '../types';
import { CreditCard } from './CreditCard';
import { CardEditDrawer } from './CardEditDrawer';

const initialCards: Card[] = [
  {
    id: '1',
    name: 'Chase Freedom Unlimited',
    last4: '4242',
    bank: 'Chase',
    color: '#114499',
    type: 'visa',
    annualFee: 0,
    activationDate: '2023',
    isHighConfidence: true
  },
  {
    id: '2',
    name: 'Amex Platinum',
    last4: '1004',
    bank: 'American Express',
    color: '#717182',
    type: 'amex',
    annualFee: 695,
    activationDate: '2024'
  },
  {
    id: '3',
    name: 'Apple Card',
    last4: '8831',
    bank: 'Apple Card',
    color: '#ffffff',
    type: 'mastercard',
    annualFee: 0,
    activationDate: '2024'
  },
  {
    id: '4',
    name: 'Capital One Venture',
    last4: '5521',
    bank: 'Capital One',
    color: '#004D40',
    type: 'visa',
    annualFee: 95,
    activationDate: '2022'
  },
  {
    id: '5',
    name: 'Amex Gold',
    last4: '9902',
    bank: 'American Express',
    color: '#D4AF37',
    type: 'amex',
    annualFee: 250,
    activationDate: '2023'
  },
];

export const Wallet: React.FC = () => {
  const [cards, setCards] = useState<Card[]>(initialCards);
  const [viewMode, setViewMode] = useState<'list' | 'carousel'>('list');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCard, setSelectedCard] = useState<Card | null>(null);

  const filteredCards = cards.filter(c =>
    c.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    c.bank.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleDelete = (id: string) => {
    setCards(cards.filter(c => c.id !== id));
  };

  const handleExport = () => {
    const dataStr = JSON.stringify(cards, null, 2);
    const dataUri = 'data:application/json;charset=utf-8,' + encodeURIComponent(dataStr);
    const exportFileDefaultName = 'perkmax_wallet.json';
    const linkElement = document.createElement('a');
    linkElement.setAttribute('href', dataUri);
    linkElement.setAttribute('download', exportFileDefaultName);
    linkElement.click();
  };

  return (
    <div className="pb-40 pt-6 px-6 max-w-md mx-auto min-h-screen bg-[#F5F5F5]">
      <header className="flex justify-between items-start mb-8">
        <div>
          <h1 className="text-3xl text-primary font-bold">My Cards</h1>
          <div className="flex items-center gap-2 mt-1">
            <span className="bg-primary/10 text-primary text-[10px] font-bold px-2 py-0.5 rounded-full">
              {cards.length} ACTIVE
            </span>
            <div className="flex items-center gap-1 opacity-40 text-slate-500">
              <Lock size={10} />
              <span className="text-[9px] uppercase tracking-widest font-sans">Encrypted</span>
            </div>
          </div>
        </div>
        <div className="flex gap-2">
          <button
            onClick={() => setViewMode(v => v === 'list' ? 'carousel' : 'list')}
            className="w-10 h-10 rounded-2xl bg-white border border-gray-100 flex items-center justify-center text-slate-400 shadow-sm"
          >
            {viewMode === 'list' ? <LayoutGrid size={18} /> : <LayoutList size={18} />}
          </button>
          <button
            onClick={handleExport}
            className="w-10 h-10 rounded-2xl bg-white border border-gray-100 flex items-center justify-center text-slate-400 shadow-sm"
          >
            <Download size={18} />
          </button>
        </div>
      </header>

      {/* Search & Filter */}
      <div className="flex gap-3 mb-10">
        <div className="relative flex-1">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search by bank or card name..."
            className="w-full bg-white py-4 pl-11 pr-4 rounded-2xl border-none shadow-sm font-sans text-sm focus:ring-2 focus:ring-primary/10 transition-all outline-none"
          />
        </div>
        <button className="w-12 h-12 rounded-2xl bg-white border border-gray-100 flex items-center justify-center text-slate-400 shadow-sm">
          <Filter size={18} />
        </button>
      </div>

      {/* Cards Display */}
      <div className="relative">
        <AnimatePresence mode="popLayout">
          {filteredCards.length > 0 ? (
            viewMode === 'list' ? (
              <motion.div
                layout
                className="flex flex-col pb-20"
              >
                {filteredCards.map((card, i) => (
                  <CreditCard
                    key={card.id}
                    card={card}
                    index={i}
                    variant="list"
                    onClick={() => setSelectedCard(card)}
                  />
                ))}
              </motion.div>
            ) : (
              <motion.div
                layout
                className="flex overflow-x-auto gap-6 pb-12 snap-x px-4 no-scrollbar"
              >
                {filteredCards.map((card, i) => (
                  <div key={card.id} className="snap-center">
                    <CreditCard
                      card={card}
                      index={i}
                      variant="carousel"
                      onClick={() => setSelectedCard(card)}
                    />
                  </div>
                ))}
              </motion.div>
            )
          ) : (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="flex flex-col items-center justify-center py-20 text-center"
            >
              <div className="w-20 h-20 rounded-full bg-gray-100 flex items-center justify-center mb-6">
                <CardIcon className="text-slate-300" size={32} />
              </div>
              <h3 className="text-xl font-serif text-slate-800 mb-2">No cards found</h3>
              <p className="text-sm text-slate-400 font-sans max-w-[200px]">Adjust your search or add a new card to your wallet.</p>
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      {/* Add Card FAB */}
      {/* Add Card FAB - Now functional */}
      <motion.button
        whileHover={{ scale: 1.05 }}
        whileTap={{ scale: 0.95 }}
        onClick={() => {
          // Creating a new empty card template
          const newCard: Card = {
            id: Math.random().toString(36).substr(2, 9),
            name: '',
            last4: '',
            bank: '',
            color: '#000000',
            type: 'visa',
            annualFee: 0,
            activationDate: new Date().getFullYear().toString()
          };
          setSelectedCard(newCard);
        }}
        className="fixed bottom-24 right-6 w-16 h-16 rounded-[24px] rounded-tr-lg bg-primary text-white flex items-center justify-center shadow-2xl shadow-primary/30 z-50 border border-white/10"
      >
        <Plus size={32} />
      </motion.button>

      {/* Bottom Disclaimer */}
      <div className="mt-12 text-center opacity-30 group">
        <div className="flex items-center justify-center gap-1.5 mb-1">
          <Lock size={10} />
          <span className="text-[9px] uppercase tracking-[0.2em] font-sans">Bank-Grade Encryption</span>
        </div>
        <p className="text-[8px] font-sans px-10">
          PerkMax never stores your full card number, CVV, or expiration date. All metadata is stored locally and encrypted.
        </p>
      </div>

      {/* Edit Drawer */}
      <AnimatePresence>
        {selectedCard && (
          <CardEditDrawer
            card={selectedCard}
            onClose={() => setSelectedCard(null)}
            onDelete={handleDelete}
          />
        )}
      </AnimatePresence>
    </div>
  );
};
