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
import { POPULAR_CARDS } from '../../data/cards';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "../components/ui/dialog";
import { ScrollArea } from "../components/ui/scroll-area";

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
  const [isAddCardOpen, setIsAddCardOpen] = useState(false);

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
    <div className="pb-40 pt-6 px-6 max-w-md mx-auto min-h-screen bg-background">
      <header className="flex justify-between items-start mb-8">
        <div>
          <h1 className="text-3xl text-primary font-serif font-medium">My Cards</h1>
          <div className="flex items-center gap-2 mt-1">
            <span className="bg-primary/10 text-primary text-[10px] font-bold px-2 py-0.5 rounded-md border border-primary/20">
              {cards.length} ACTIVE
            </span>
            <div className="flex items-center gap-1 opacity-40 text-muted-foreground">
              <Lock size={10} />
              <span className="text-[9px] uppercase tracking-widest font-sans">Encrypted</span>
            </div>
          </div>
        </div>
        <div className="flex gap-2">
          <button
            onClick={() => setViewMode(v => v === 'list' ? 'carousel' : 'list')}
            className="w-10 h-10 rounded-lg bg-card border border-border flex items-center justify-center text-muted-foreground shadow-sm hover:border-primary/20 transition-colors"
          >
            {viewMode === 'list' ? <LayoutGrid size={18} /> : <LayoutList size={18} />}
          </button>
          <button
            onClick={handleExport}
            className="w-10 h-10 rounded-lg bg-card border border-border flex items-center justify-center text-muted-foreground shadow-sm hover:border-primary/20 transition-colors"
          >
            <Download size={18} />
          </button>
        </div>
      </header>

      {/* Search & Filter */}
      <div className="flex gap-3 mb-10">
        <div className="relative flex-1">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-muted-foreground" size={18} />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search by bank or card name..."
            className="w-full bg-card py-4 pl-11 pr-4 rounded-xl border border-border shadow-sm font-sans text-sm focus:ring-1 focus:ring-primary focus:border-primary transition-all outline-none"
          />
        </div>
        <button className="w-12 h-12 rounded-xl bg-card border border-border flex items-center justify-center text-muted-foreground shadow-sm hover:border-primary/20 transition-colors">
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
              <div className="w-20 h-20 rounded-full bg-muted flex items-center justify-center mb-6">
                <CardIcon className="text-muted-foreground" size={32} />
              </div>
              <h3 className="text-xl font-serif text-foreground mb-2">No cards found</h3>
              <p className="text-sm text-muted-foreground font-sans max-w-[200px]">Adjust your search or add a new card to your wallet.</p>
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      {/* Add Card FAB */}
      <motion.button
        whileHover={{ scale: 1.05 }}
        whileTap={{ scale: 0.95 }}
        onClick={() => setIsAddCardOpen(true)}
        className="fixed bottom-24 right-6 w-14 h-14 rounded-xl bg-primary text-primary-foreground flex items-center justify-center shadow-lg shadow-primary/20 z-50 border border-white/10"
      >
        <Plus size={28} />
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

      {/* Add Card Dialog */}
      <Dialog open={isAddCardOpen} onOpenChange={setIsAddCardOpen}>
        <DialogContent className="sm:max-w-[425px]">
          <DialogHeader>
            <DialogTitle>Add New Card</DialogTitle>
            <DialogDescription>
              Select a card to add to your wallet.
            </DialogDescription>
          </DialogHeader>
          <ScrollArea className="h-[300px] w-full rounded-md border p-4">
            <div className="grid grid-cols-1 gap-2">
              {POPULAR_CARDS.map((card, index) => (
                <button
                  key={index}
                  onClick={() => {
                    const newCard: Card = {
                      ...card,
                      id: Math.random().toString(36).substr(2, 9),
                      last4: '0000',
                      activationDate: new Date().getFullYear().toString(),
                    } as Card;
                    setCards([newCard, ...cards]);
                    setIsAddCardOpen(false);
                    setSelectedCard(newCard); // Optionally open edit drawer immediately
                  }}
                  className="flex items-center gap-3 p-3 rounded-lg hover:bg-slate-100 transition-colors text-left"
                >
                  <div
                    className="w-10 h-6 rounded bg-gradient-to-br from-gray-700 to-gray-900 shadow-sm"
                    style={{ backgroundColor: card.color }}
                  />
                  <div>
                    <div className="font-medium text-sm">{card.name}</div>
                    <div className="text-xs text-gray-500">{card.bank} • {card.type}</div>
                  </div>
                </button>
              ))}
            </div>
          </ScrollArea>
        </DialogContent>
      </Dialog>
    </div>
  );
};
