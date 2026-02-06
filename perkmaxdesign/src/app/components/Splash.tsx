import React, { useEffect, useState } from 'react';
import { motion } from 'motion/react';
import { ShieldCheck, Fingerprint } from 'lucide-react';

interface SplashProps {
  onComplete: () => void;
}

export const Splash: React.FC<SplashProps> = ({ onComplete }) => {
  const [stage, setStage] = useState<'logo' | 'biometric'>('logo');

  useEffect(() => {
    const timer = setTimeout(() => {
      setStage('biometric');
    }, 2000);
    return () => clearTimeout(timer);
  }, []);

  return (
    <div className="fixed inset-0 bg-primary flex flex-col items-center justify-center text-white z-[100]">
      {stage === 'logo' ? (
        <motion.div
          initial={{ scale: 0.8, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          exit={{ scale: 1.2, opacity: 0 }}
          className="flex flex-col items-center"
        >
          <div className="w-24 h-24 rounded-[32px] bg-white flex items-center justify-center mb-6 shadow-2xl">
            <ShieldCheck size={48} className="text-primary" />
          </div>
          <h1 className="text-4xl font-bold font-serif tracking-tight">PerkMax</h1>
          <p className="text-accent text-sm font-sans tracking-[0.3em] uppercase mt-2">Professional Advisory</p>
        </motion.div>
      ) : (
        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          className="flex flex-col items-center max-w-xs text-center px-6"
        >
          <div className="w-20 h-20 rounded-full bg-white/10 flex items-center justify-center mb-10 border border-white/20">
            <Fingerprint size={40} className="text-accent" />
          </div>
          <h2 className="text-2xl font-serif mb-3">Welcome Back</h2>
          <p className="text-white/60 text-sm font-sans mb-12">Confirm your identity to access your encrypted vault.</p>
          
          <button 
            onClick={onComplete}
            className="w-full bg-accent text-primary py-5 rounded-2xl font-sans font-bold shadow-xl shadow-accent/20 active:scale-95 transition-transform"
          >
            Sign In with FaceID
          </button>
          
          <button className="mt-6 text-white/40 text-sm font-medium font-sans">
            Use Passcode
          </button>
        </motion.div>
      )}

      {/* Hand-drawn style illustration at bottom */}
      <div className="absolute bottom-10 opacity-20 pointer-events-none">
         <svg width="200" height="100" viewBox="0 0 200 100" fill="none" stroke="white" strokeWidth="1" strokeLinecap="round">
            <path d="M20,80 Q50,20 100,80 T180,80" />
            <circle cx="100" cy="50" r="2" fill="white" />
            <path d="M90,40 L110,40 L100,60 Z" fill="white" />
         </svg>
      </div>
    </div>
  );
};
