import React, { useState } from 'react';
import { motion } from 'motion/react';
import { Search, Info, ShieldCheck, ChevronRight, Zap } from 'lucide-react';
import { Card, Recommendation } from '../types';
import { toast } from 'sonner';

interface DashboardProps {
  onShowDetail: (rec: Recommendation) => void;
}

const mockRecommendation: Recommendation = {
  merchantName: 'Best Buy',
  card: {
    id: '1',
    name: 'Chase Freedom Unlimited',
    last4: '4242',
    bank: 'Chase',
    color: '#114499',
    type: 'visa'
  },
  confidence: 'HIGH',
  pointsMultiplier: 3.5,
  reason: 'Electronics category bonus + Seasonal 1% kicker',
  savedAmount: 52.50
};

export const Dashboard: React.FC<DashboardProps> = ({ onShowDetail }) => {
  const [search, setSearch] = useState('');

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    if (search.trim()) {
      toast.info(`Searching for "${search}"...`, {
        description: "Checking current offers and card network compatibility."
      });
    }
  };

  const handleAutoDetect = () => {
    if (!navigator.geolocation) {
      toast.error("Geolocation is not supported by your browser");
      return;
    }

    toast.info("Locating...", { description: "Requesting browser location access." });

    navigator.geolocation.getCurrentPosition(async (position) => {
      const { latitude, longitude } = position.coords;
      try {
        const response = await fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${latitude}&lon=${longitude}`);
        const data = await response.json();
        const address = data.address;
        const locationName = address.city || address.town || address.village || address.county || "Unknown Location";

        setSearch(locationName);
        toast.success("Location Detect", { description: `Found you in ${locationName}` });
      } catch (error) {
        setSearch(`${latitude.toFixed(4)}, ${longitude.toFixed(4)}`);
        toast.success("Location Services Enabled", { description: "Could not fetch address name, showing coordinates." });
      }
    }, (error) => {
      toast.error("Location Error", { description: error.message });
    });
  };

  return (
    <div className="pb-32 pt-6 px-6 max-w-md mx-auto bg-background min-h-screen">
      {/* Header */}
      <header className="flex justify-between items-start mb-8">
        <div>
          <h1 className="text-3xl text-primary font-serif font-medium">PerkMax</h1>
          <p className="text-muted-foreground font-sans text-sm tracking-wide">Financial Co-pilot</p>
        </div>
        <div className="w-10 h-10 rounded-lg bg-card flex items-center justify-center shadow-sm border border-border text-primary">
          <ShieldCheck size={20} />
        </div>
      </header>

      {/* Hero Search */}
      <form onSubmit={handleSearch} className="relative mb-8">
        <div className="absolute inset-y-0 left-4 flex items-center pointer-events-none">
          <Search size={18} className="text-muted-foreground" />
        </div>
        <input
          type="text"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Where are you shopping?"
          className="w-full bg-card border border-border py-4 pl-12 pr-4 rounded-xl shadow-sm font-sans focus:ring-1 focus:ring-primary focus:border-primary transition-all outline-none text-foreground placeholder:text-muted-foreground/70"
        />
        <div className="absolute right-3 inset-y-0 flex items-center">
          <button
            type="button"
            onClick={handleAutoDetect}
            className="px-3 py-1.5 bg-muted rounded-md text-[10px] font-bold text-muted-foreground border border-border hover:bg-muted/80 transition-colors tracking-wider"
          >
            AUTO-DETECT
          </button>
        </div>
      </form>

      {/* Recommendation Hero */}
      <div className="mb-10">
        <div className="flex justify-between items-end mb-4 px-1">
          <h2 className="text-xl text-primary font-serif">Recommendation</h2>
          <div className="flex items-center gap-1.5 bg-primary/5 px-2.5 py-1 rounded-md border border-primary/20">
            <div className="w-1.5 h-1.5 bg-green-600 rounded-full animate-pulse" />
            <span className="text-[10px] font-bold text-primary tracking-wider uppercase">High Confidence</span>
          </div>
        </div>

        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          whileHover={{ scale: 1.01 }}
          whileTap={{ scale: 0.99 }}
          onClick={() => onShowDetail(mockRecommendation)}
          className="relative overflow-hidden cursor-pointer"
        >
          {/* Asymmetric Design Container */}
          <div
            className="bg-primary text-primary-foreground p-8 pb-10 rounded-[36px] rounded-br-[100px] border border-primary-foreground/10 shadow-xl relative z-10"
            style={{
              backgroundImage: 'radial-gradient(circle at 100% 0%, rgba(212, 175, 55, 0.15) 0%, transparent 40%)'
            }}
          >
            <div className="flex justify-between items-start mb-12">
              <div>
                <p className="text-accent text-sm font-sans font-medium mb-1 tracking-wide">Use this card at {mockRecommendation.merchantName}</p>
                <h3 className="text-2xl font-serif tracking-tight leading-tight italic">{mockRecommendation.card.name}</h3>
              </div>
              <div className="text-right">
                <span className="text-3xl font-bold text-accent italic tracking-tighter">{mockRecommendation.pointsMultiplier}x</span>
                <p className="text-[10px] text-primary-foreground/60 font-sans uppercase tracking-widest">Points</p>
              </div>
            </div>

            <div className="flex justify-between items-end">
              <div>
                <p className="text-primary-foreground/50 text-[10px] font-sans tracking-[0.2em] mb-1 uppercase">Card Ending In</p>
                <div className="flex items-center gap-2">
                  <div className="w-8 h-5 bg-white/10 rounded-sm flex items-center justify-center border border-white/10">
                    <span className="text-[8px] font-bold italic">VISA</span>
                  </div>
                  <span className="text-lg font-sans tracking-widest font-medium opacity-90">•••• {mockRecommendation.card.last4}</span>
                </div>
              </div>
              <div className="bg-white/5 backdrop-blur-md rounded-lg p-2 px-3 flex items-center gap-2 border border-white/10">
                <div className="w-6 h-6 rounded-full bg-accent flex items-center justify-center shadow-sm text-primary">
                  <Zap size={14} className="fill-current" />
                </div>
                <span className="text-xs font-bold font-sans tracking-wide">OPTIMIZED</span>
              </div>
            </div>
          </div>
        </motion.div>
      </div>

      {/* Quick Stats */}
      <div className="grid grid-cols-2 gap-4 mb-10">
        <div className="bg-card p-5 rounded-xl border border-border shadow-none relative overflow-hidden group hover:border-primary/20 transition-colors">
          <div className="absolute top-0 right-0 w-12 h-12 bg-accent/5 rounded-bl-xl transition-all group-hover:scale-110" />
          <p className="text-muted-foreground text-xs font-sans mb-1 uppercase tracking-wider">Total Saved</p>
          <p className="text-2xl font-serif text-primary font-bold tracking-tight">$428.12</p>
        </div>
        <div className="bg-card p-5 rounded-xl border border-border shadow-none relative overflow-hidden group hover:border-primary/20 transition-colors">
          <div className="absolute top-0 right-0 w-12 h-12 bg-primary/5 rounded-bl-xl transition-all group-hover:scale-110" />
          <p className="text-muted-foreground text-xs font-sans mb-1 uppercase tracking-wider">Active Goals</p>
          <p className="text-2xl font-serif text-primary font-bold tracking-tight">2</p>
        </div>
      </div>

      {/* Recent History Teaser */}
      <div>
        <div className="flex justify-between items-center mb-4 px-1">
          <h2 className="text-lg text-primary font-serif">Recent Wins</h2>
          <button className="text-xs font-bold text-accent uppercase tracking-widest flex items-center gap-1 hover:text-accent/80">
            History <ChevronRight size={14} />
          </button>
        </div>
        <div className="space-y-3">
          {[
            { name: 'Starbucks', date: 'Today', saved: '$1.40', icon: '☕' },
            { name: 'Amazon', date: 'Yesterday', saved: '$12.20', icon: '📦' },
          ].map((item, i) => (
            <div key={i} className="bg-card p-4 rounded-xl border border-border flex justify-between items-center hover:border-primary/20 transition-colors">
              <div className="flex items-center gap-4">
                <div className="w-10 h-10 rounded-lg bg-muted flex items-center justify-center text-lg border border-border">
                  {item.icon}
                </div>
                <div>
                  <p className="font-serif font-bold text-foreground tracking-tight">{item.name}</p>
                  <p className="text-xs text-muted-foreground font-sans">{item.date}</p>
                </div>
              </div>
              <p className="text-green-600 font-bold font-sans">+{item.saved}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
