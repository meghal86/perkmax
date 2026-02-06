import React from 'react';
import { Home, Wallet, History, Target, Gift } from 'lucide-react';
import { motion } from 'motion/react';

interface NavigationProps {
  activeTab: string;
  setActiveTab: (tab: string) => void;
}

export const Navigation: React.FC<NavigationProps> = ({ activeTab, setActiveTab }) => {
  const tabs = [
    { id: 'dashboard', icon: Home, label: 'Home' },
    { id: 'wallet', icon: Wallet, label: 'Wallet' },
    { id: 'history', icon: History, label: 'History' },
    { id: 'planner', icon: Target, label: 'Planner' },
    { id: 'redeem', icon: Gift, label: 'Redeem' },
  ];

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-100 px-6 py-4 flex justify-between items-center z-50 rounded-t-3xl shadow-lg">
      {tabs.map((tab) => {
        const Icon = tab.icon;
        const isActive = activeTab === tab.id;
        
        return (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id)}
            className="flex flex-col items-center gap-1 relative group"
          >
            <div className={`p-2 rounded-xl transition-all duration-300 ${isActive ? 'bg-primary/10' : 'group-hover:bg-gray-50'}`}>
              <Icon
                size={22}
                strokeWidth={isActive ? 2.5 : 2}
                className={isActive ? 'text-primary' : 'text-gray-400'}
              />
            </div>
            {isActive && (
              <motion.div
                layoutId="nav-indicator"
                className="absolute -bottom-1 w-1 h-1 bg-primary rounded-full"
              />
            )}
          </button>
        );
      })}
    </nav>
  );
};
