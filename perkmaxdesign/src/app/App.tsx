import React, { useState, useEffect } from 'react';
import { AnimatePresence } from 'motion/react';
import { Dashboard } from './components/Dashboard';
import { RecommendationDetail } from './components/RecommendationDetail';
import { Wallet } from './components/Wallet';
import { History } from './components/History';
import { Planner } from './components/Planner';
import { Redeem } from './components/Redeem';
import { Navigation } from './components/Navigation';
import { Splash } from './components/Splash';
import { ChatBot } from './components/ChatBot';
import { Recommendation } from './types';
import { Toaster } from 'sonner';

export default function App() {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [selectedRec, setSelectedRec] = useState<Recommendation | null>(null);
  const [isInitializing, setIsInitializing] = useState(true);
  const [isChatOpen, setIsChatOpen] = useState(false);

  if (isInitializing) {
    return <Splash onComplete={() => setIsInitializing(false)} />;
  }

  const renderContent = () => {
    switch (activeTab) {
      case 'dashboard':
        return <Dashboard onShowDetail={setSelectedRec} />;
      case 'wallet':
        return <Wallet />;
      case 'history':
        return <History />;
      case 'planner':
        return <Planner />;
      case 'redeem':
        return <Redeem />;
      default:
        return <Dashboard onShowDetail={setSelectedRec} />;
    }
  };

  return (
    <div className="min-h-screen bg-[#F5F5F5] font-sans selection:bg-primary/10 selection:text-primary">
      <Toaster position="top-center" richColors />
      {/* Main Content Area */}
      <main className="pb-20">
        <AnimatePresence mode="wait">
          <div key={activeTab}>
            {renderContent()}
          </div>
        </AnimatePresence>
      </main>

      {/* Detail Overlay */}
      <AnimatePresence>
        {selectedRec && (
          <RecommendationDetail 
            rec={selectedRec} 
            onClose={() => setSelectedRec(null)} 
          />
        )}
      </AnimatePresence>

      {/* Chat Bot Toggle */}
      <ChatBot isOpen={isChatOpen} setIsOpen={setIsChatOpen} />

      {/* Global Navigation */}
      <Navigation 
        activeTab={activeTab} 
        setActiveTab={setActiveTab} 
      />
      
      {/* Status Bar / Notch Padding for mobile feel */}
      <div className="fixed top-0 inset-x-0 h-8 bg-transparent pointer-events-none z-[100]" />
    </div>
  );
}
