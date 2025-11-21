import React, { useState, useEffect, useRef, useMemo } from 'react';
import { 
  Coffee, User, Star, Home, ShoppingBag, ChevronRight, LogOut, MapPin, Gift, X, Plus, Minus, 
  CheckCircle, Bell, Search, ArrowRight, QrCode, Store, Bike, Navigation, Trash2, Loader, AlertTriangle, LogIn, Receipt, Download, Sparkles, Sun, Moon, ShieldAlert
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { initializeApp } from 'firebase/app';
import { getAuth, onAuthStateChanged, GoogleAuthProvider, signInWithPopup, signOut, deleteUser } from 'firebase/auth';

// ==============================================================================
// ⚙️ CONFIGURACIÓN Y FIREBASE
// ==============================================================================

const API_BASE_URL = 'https://salmon-snail-279120.hostingersite.com/wp-json/enigma-loyverse/v1'; 
const WHATSAPP_NUMBER = "584247100157"; 
const MODO_PRUEBA_ACTIVO = false; 

const FALLBACK_IMAGE = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="; 

// Usamos las URLs remotas para asegurar que carguen
const LOGO_DARK = "https://salmon-snail-279120.hostingersite.com/wp-content/uploads/2025/11/ENIGMA-MARCA-REGISTRADA-4.png"; // Blanco para fondo oscuro
const LOGO_LIGHT = "https://salmon-snail-279120.hostingersite.com/wp-content/uploads/2025/11/ENIGMA-MARCA-REGISTRADA-2.png"; // Negro para fondo claro

const firebaseConfig = {
  apiKey: "AIzaSyAipSgiKQhJ-o6Z-rM4RYZNoOmJTHLShps",
  authDomain: "enigma-cafe-app.firebaseapp.com",
  projectId: "enigma-cafe-app",
  storageBucket: "enigma-cafe-app.firebasestorage.app",
  messagingSenderId: "361671667060",
  appId: "1:361671667060:web:94e488f0f82a39e9e15021",
  measurementId: "G-MLH0HSZ6FJ"
};

let app, auth;
try {
    if (firebaseConfig && firebaseConfig.apiKey && !MODO_PRUEBA_ACTIVO) {
        app = initializeApp(firebaseConfig);
        auth = getAuth(app);
    }
} catch (e) { console.error("🔥 Error Firebase:", e); }

// ==============================================================================
// 🎨 DESIGN SYSTEM & UTILS (Ultra-Premium)
// ==============================================================================

const GlobalStyles = () => (
    <style>{`
        :root {
            --bg-primary: #050505;
            --bg-secondary: #121212;
            --card-bg: #18181b;
            --text-primary: #ffffff;
            --text-secondary: #a1a1aa;
            --accent: #14b8a6;
            --border-light: rgba(255,255,255,0.06);
            --glass-bg: rgba(18, 18, 18, 0.7);
            --glass-border: rgba(255, 255, 255, 0.08);
            --shadow-card: 0 8px 32px rgba(0,0,0,0.4);
            --input-bg: #27272a;
            --skeleton-start: #1c1c1e;
            --skeleton-mid: #2a2a2d;
            --skeleton-end: #1c1c1e;
        }

        [data-theme="light"] {
            --bg-primary: #F5F5F7;
            --bg-secondary: #FFFFFF;
            --card-bg: #FFFFFF;
            --text-primary: #1D1D1F;
            --text-secondary: #86868B;
            --accent: #000000; /* Minimalista puro */
            --border-light: rgba(0,0,0,0.04);
            --glass-bg: rgba(255, 255, 255, 0.8);
            --glass-border: rgba(0, 0, 0, 0.04);
            --shadow-card: 0 4px 24px rgba(0,0,0,0.04);
            --input-bg: #EBEBF0;
            --skeleton-start: #e5e7eb;
            --skeleton-mid: #f3f4f6;
            --skeleton-end: #e5e7eb;
        }

        .no-scrollbar::-webkit-scrollbar { display: none; }
        .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
        .safe-area-pb { padding-bottom: env(safe-area-inset-bottom); }
        
        body { 
            overscroll-behavior-y: none; 
            background-color: var(--bg-primary); 
            color: var(--text-primary);
            transition: background-color 0.5s cubic-bezier(0.32, 0.72, 0, 1), color 0.5s; 
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            -webkit-font-smoothing: antialiased;
        }

        .card-premium { 
            background: var(--card-bg); 
            color: var(--text-primary); 
            border: 1px solid var(--border-light); 
            box-shadow: var(--shadow-card);
        }

        .glass-premium {
            background: var(--glass-bg);
            backdrop-filter: blur(24px);
            -webkit-backdrop-filter: blur(24px);
            border-top: 1px solid var(--glass-border);
        }
        
        .input-premium { 
            background: var(--input-bg); 
            color: var(--text-primary); 
            border: 1px solid transparent;
            transition: all 0.3s ease;
        }
        .input-premium:focus {
            background: var(--card-bg);
            box-shadow: 0 0 0 2px var(--accent);
        }

        /* Mesh Gradient Mejorado */
        .mesh-bg {
            position: fixed; inset: 0; z-index: -1;
            opacity: 0.5;
            background: 
                radial-gradient(at 0% 0%, rgba(20, 184, 166, 0.08) 0px, transparent 50%),
                radial-gradient(at 100% 0%, rgba(139, 92, 246, 0.05) 0px, transparent 50%),
                radial-gradient(at 100% 100%, rgba(20, 184, 166, 0.05) 0px, transparent 50%);
            filter: blur(100px);
            pointer-events: none;
        }
        [data-theme="light"] .mesh-bg { opacity: 0.8; mix-blend-mode: multiply; }

        @keyframes shine { to { background-position-x: -200%; } }
        .skeleton {
            background: var(--skeleton-start);
            background: linear-gradient(110deg, var(--skeleton-start) 8%, var(--skeleton-mid) 18%, var(--skeleton-end) 33%);
            background-size: 200% 100%;
            animation: 1.5s shine linear infinite;
        }
    `}</style>
);

const AppContainer = ({ children, theme }) => (
    <div className="min-h-screen font-sans selection:bg-teal-500/30 overflow-x-hidden pb-32 relative transition-colors duration-500" data-theme={theme}>
        <GlobalStyles />
        <div className="mesh-bg" />
        {children}
    </div>
);

const useScrollToTop = (trigger) => {
    useEffect(() => {
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }, [trigger]);
};

const GlassBlur = ({ className = "", children }) => (
    <div className={`glass-premium ${className}`}>
        {children}
    </div>
);

const BouncyButton = ({ children, onClick, className = "", ...props }) => (
    <motion.button
        whileTap={{ scale: 0.96 }}
        transition={{ type: "spring", stiffness: 500, damping: 20 }}
        onClick={onClick}
        className={`cursor-pointer relative overflow-hidden ${className}`}
        {...props}
    >
        {children}
    </motion.button>
);

const PremiumCard = ({ children, className = "", onClick, delay = 0 }) => (
    <motion.div 
        initial={{ opacity: 0 }} 
        animate={{ opacity: 1 }}
        transition={{ delay, duration: 0.4 }} 
        onClick={onClick}
        className={`card-premium active:scale-[0.98] transition-transform duration-300 rounded-[28px] overflow-hidden relative group ${className}`}
        layout="position" 
    >
        {children}
    </motion.div>
);

const SkeletonCard = () => (
    <div className="h-[260px] rounded-[28px] skeleton w-full border border-[var(--border-light)]"></div>
);

// ==============================================================================
// 📱 VISTAS
// ==============================================================================

const InstallBanner = ({ onInstall, onClose, isIOS }) => (
    <motion.div 
        initial={{ y: 100, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        exit={{ y: 100, opacity: 0 }}
        drag="x"
        dragConstraints={{ left: 0, right: 0 }}
        dragElastic={0.2}
        onDragEnd={(e, { offset, velocity }) => {
            if (offset.x > 50 || velocity.x > 500) onClose();
        }}
        className="fixed bottom-24 left-4 right-4 z-40 touch-none"
    >
        <div className="bg-[var(--card-bg)] rounded-[24px] p-4 shadow-2xl border border-[var(--border-light)] flex items-center gap-4 relative overflow-hidden">
            <div className="bg-gradient-to-br from-teal-400 to-teal-600 w-12 h-12 rounded-xl flex items-center justify-center flex-shrink-0 shadow-lg">
                <img src="logo-white.png" className="w-8 opacity-90" onError={(e) => e.target.style.display='none'} />
            </div>
            <div className="flex-1 min-w-0">
                <h3 className="font-bold text-primary text-sm">Instalar App</h3>
                <p className="text-xs text-secondary truncate">
                    {isIOS ? 'Toca "Compartir" y "Agregar a Inicio"' : 'Acceso rápido y notificaciones'}
                </p>
            </div>
            {!isIOS && (
                <BouncyButton onClick={onInstall} className="bg-[var(--text-primary)] text-[var(--bg-primary)] px-4 py-2 rounded-full text-xs font-bold shadow-lg">
                    Instalar
                </BouncyButton>
            )}
            <button onClick={onClose} className="absolute top-2 right-2 p-2 bg-[var(--bg-secondary)] rounded-full text-primary hover:bg-[var(--accent)] hover:text-white transition-colors shadow-md z-50"><X size={16}/></button>
        </div>
    </motion.div>
);

const HomeTab = ({ user, userStatus, promos, rewardsLevels, theme }) => {
    const hour = new Date().getHours();
    let greeting = "Buenas noches";
    if(hour < 12) greeting = "Buenos días";
    else if(hour < 19) greeting = "Buenas tardes";

    const currentName = userStatus.tier?.name || 'Miembro';
    const basePoints = userStatus.tier?.min_points ?? 0;
    const levels = rewardsLevels.length ? rewardsLevels : [];
    const nextTier = userStatus.tier?.next_level || levels.find(l => l.min_points > userStatus.points);
    const targetPoints = nextTier ? nextTier.min_points : basePoints + 500;
    const remaining = Math.max(targetPoints - userStatus.points, 0);
    const progress = Math.min(Math.max(((userStatus.points - basePoints) / Math.max(targetPoints - basePoints, 1)) * 100, 0), 100);

    const avatarUrl = user?.photoURL;

    return (
        <div className="px-6 pt-16 pb-6 space-y-8">
            <motion.div initial={{opacity:0, y:10}} animate={{opacity:1, y:0}} className="flex justify-between items-center">
                <div>
                    <p className="text-secondary text-sm font-medium mb-0.5 tracking-wide opacity-80">{greeting},</p>
                    <h1 className="text-3xl font-bold text-primary tracking-tight">{user?.name?.split(' ')[0] || 'Invitado'}</h1>
                </div>
                <div className="relative group cursor-pointer">
                    {avatarUrl ? (
                        <img src={avatarUrl} alt="Perfil" className="w-12 h-12 rounded-full object-cover border-2 border-[var(--bg-secondary)] shadow-lg" />
                    ) : (
                        <div className="w-12 h-12 rounded-full bg-gradient-to-br from-teal-500 to-teal-700 flex items-center justify-center shadow-lg text-white font-bold text-lg">
                            {user?.name?.charAt(0) || <User size={20}/>}
                        </div>
                    )}
                </div>
            </motion.div>

            <motion.div 
                initial={{scale:0.95, opacity:0}} animate={{scale:1, opacity:1}} transition={{delay:0.1}}
                className="relative w-full h-56 rounded-[32px] overflow-hidden p-7 flex flex-col justify-between shadow-2xl border border-white/10"
                style={{ background: 'linear-gradient(135deg, #09090b 0%, #000000 100%)' }} 
            >
                <div className="absolute top-0 right-0 w-48 h-48 bg-teal-500/20 blur-[80px] rounded-full pointer-events-none"></div>
                
                <div className="relative z-10 flex justify-between items-start">
                    <div>
                        <p className="text-zinc-500 text-[10px] font-bold uppercase tracking-[0.2em] mb-2">ENIGMA REWARDS</p>
                        <h2 className="text-3xl font-black text-white flex items-center gap-2 tracking-tight">
                            {currentName} <Sparkles size={20} className="text-amber-400 fill-amber-400 animate-pulse"/>
                        </h2>
                    </div>
                    <div className="bg-white/10 backdrop-blur-md px-4 py-1.5 rounded-full border border-white/10 shadow-lg">
                        <span className="text-sm font-bold text-white">{userStatus.points} pts</span>
                    </div>
                </div>

                <div className="relative z-10">
                    <div className="flex justify-between text-xs text-zinc-400 mb-3 font-medium tracking-wide">
                        <span>Próximo: {nextTier ? nextTier.name : 'Máximo Nivel'}</span>
                        <span>{remaining} pts más</span>
                    </div>
                    <div className="h-2.5 w-full bg-white/10 rounded-full overflow-hidden backdrop-blur-sm">
                        <motion.div 
                            initial={{width:0}} animate={{width: `${progress}%`}} transition={{duration:1.5, ease:"circOut"}}
                            className="h-full bg-gradient-to-r from-teal-400 to-teal-600 shadow-[0_0_20px_rgba(20,184,166,0.5)]"
                        />
                    </div>
                    <p className="text-[11px] text-zinc-500 mt-4 leading-relaxed max-w-[90%]">
                        {userStatus.tier?.perks || 'Acumula puntos con cada sorbo y desbloquea experiencias exclusivas.'}
                    </p>
                </div>
            </motion.div>

            <div>
                <h3 className="text-lg font-bold text-primary mb-4 flex items-center gap-2">Para ti hoy</h3>
                <div className="flex gap-4 overflow-x-auto no-scrollbar pb-4 -mx-6 px-6">
                    {promos.length > 0 ? promos.map((promo) => (
                        <motion.div 
                            key={promo.id} 
                            whileTap={{scale:0.95}}
                            className="min-w-[280px] h-36 card-premium rounded-[24px] p-5 flex items-center gap-5 relative overflow-hidden shadow-lg"
                        >
                            <div className="w-16 h-16 bg-[var(--bg-primary)] rounded-2xl flex items-center justify-center flex-shrink-0 border border-[var(--border-light)] shadow-inner">
                                <QrCode size={32} className="text-[var(--accent)] opacity-80"/>
                            </div>
                            <div className="flex-1 min-w-0">
                                <span className="text-[10px] font-bold text-[var(--accent)] uppercase tracking-widest border border-[var(--accent)] px-2 py-0.5 rounded-full">Cupón</span>
                                <h4 className="font-bold text-primary text-xl leading-tight mt-2 mb-1 truncate">{promo.title}</h4>
                                <p className="text-secondary text-xs font-mono opacity-70">{promo.code}</p>
                            </div>
                        </motion.div>
                    )) : (
                        <div className="w-full text-center py-12 border border-dashed border-[var(--border-light)] rounded-[24px] opacity-50">
                            <p className="text-secondary text-sm">No hay promociones activas.</p>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
};

const MenuTab = ({ items, activeCategory, setActiveCategory, categories, onItemClick, searchQuery, setSearchQuery, isLoading, theme }) => {
    const headerBg = theme === 'light' ? 'rgba(245, 245, 247, 0.85)' : 'rgba(5, 5, 5, 0.85)';

    return (
        <div className="px-6 pt-20 pb-6 min-h-screen">
            <motion.div initial={{opacity:0}} animate={{opacity:1}} className="sticky top-0 z-30 -mx-6 px-6 pb-4 pt-2 transition-colors duration-500" style={{ background: headerBg, backdropFilter: 'blur(20px)' }}>
                <h1 className="text-3xl font-bold text-primary mb-5">Menú</h1>
                
                <div className="relative mb-6 group">
                    <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                        <Search size={18} className="text-secondary group-focus-within:text-primary transition-colors"/>
                    </div>
                    <input 
                        type="text" 
                        placeholder="Buscar..." 
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="input-premium w-full rounded-2xl py-3.5 pl-12 pr-4 text-sm placeholder-zinc-500 outline-none font-medium"
                    />
                </div>

                <div className="overflow-x-auto no-scrollbar flex gap-3 pb-2">
                    {categories.map((cat, i) => (
                        <button 
                            key={i} 
                            onClick={() => setActiveCategory(cat)}
                            className={`px-5 py-2.5 rounded-full text-xs font-bold whitespace-nowrap transition-all duration-300 ${activeCategory === cat ? 'bg-primary text-white shadow-lg scale-105' : 'bg-[var(--card-bg)] text-secondary border border-[var(--border-light)]'}`}
                            style={activeCategory === cat ? { backgroundColor: 'var(--text-primary)', color: 'var(--bg-primary)' } : {}}
                        >
                            {cat}
                        </button>
                    ))}
                </div>
            </motion.div>

            <div className="grid grid-cols-2 gap-4 mt-4 pb-20">
                {isLoading ? (
                    [1,2,3,4,5,6].map(n => <SkeletonCard key={n}/>)
                ) : items.length > 0 ? (
                    items.map((item, i) => (
                        <PremiumCard key={item.id} onClick={() => onItemClick(item)} delay={i * 0.03} className="h-auto min-h-[260px] flex flex-col justify-between">
                            <div className="h-40 relative overflow-hidden bg-[var(--bg-secondary)]">
                                <img src={item.image || FALLBACK_IMAGE} className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110" onError={(e)=>{e.target.onerror=null; e.target.src=FALLBACK_IMAGE}}/>
                                <div className="absolute inset-0 bg-gradient-to-t from-[var(--card-bg)] to-transparent opacity-40" />
                            </div>
                            <div className="p-5 pt-3 flex-1 flex flex-col">
                                <div className="mb-3">
                                    <h3 className="text-base font-bold text-primary leading-tight mb-1.5 line-clamp-2">{item.name}</h3>
                                    <p className="text-secondary text-[11px] line-clamp-2 leading-relaxed opacity-80">{item.description}</p>
                                </div>
                                <div className="mt-auto flex justify-between items-end">
                                    <span className="font-bold text-primary text-lg">${item.pricing.usd}</span>
                                    <div className="w-8 h-8 bg-[var(--text-primary)] rounded-full flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform">
                                        <Plus size={16} strokeWidth={3} style={{ color: 'var(--bg-primary)' }}/>
                                    </div>
                                </div>
                            </div>
                        </PremiumCard>
                    ))
                ) : (
                    <div className="col-span-2 py-24 text-center opacity-40">
                        <Coffee size={48} className="mx-auto mb-4"/>
                        <p className="text-sm font-medium">No encontramos resultados.</p>
                    </div>
                )}
            </div>
        </div>
    );
};

const RewardsTab = ({ appUser, rewardsLevels, userStatus, onLogin, theme }) => {
    if(appUser.isGuest) {
        return (
            <div className="pt-24 px-6 pb-32 min-h-screen flex flex-col items-center justify-center text-center space-y-8">
                <div className="w-24 h-24 bg-[var(--card-bg)] rounded-full flex items-center justify-center shadow-2xl mb-4 border border-[var(--border-light)]">
                    <Gift size={40} className="text-[var(--accent)]"/>
                </div>
                <div className="space-y-2">
                    <h1 className="text-3xl font-bold text-primary">Únete a Rewards</h1>
                    <p className="text-secondary max-w-xs mx-auto leading-relaxed">Acumula puntos con cada compra y canjealos por bebidas gratis.</p>
                </div>
                <BouncyButton onClick={onLogin} className="bg-[var(--text-primary)] text-[var(--bg-primary)] px-8 py-4 rounded-full font-bold text-sm tracking-wide shadow-xl">
                    COMENZAR AHORA
                </BouncyButton>
            </div>
        );
    }

    const levels = rewardsLevels.length ? rewardsLevels : [];
    const points = userStatus.points;
    const logo = theme === 'light' ? LOGO_LIGHT : LOGO_DARK;
    const qrSrc = `https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=${encodeURIComponent(appUser.email || '')}`;

    return (
        <div className="pt-20 px-6 pb-32 space-y-6">
            <div className="card-premium rounded-[32px] p-8 flex flex-col items-center gap-6 shadow-xl border border-[var(--border-light)] relative overflow-hidden">
                <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-teal-500 via-purple-500 to-teal-500 opacity-50"></div>
                <img src={logo} alt="Enigma Café" className="h-12 object-contain opacity-100" />
                <div className="bg-white p-3 rounded-2xl shadow-lg">
                    <img src={qrSrc} alt="QR" className="w-32 h-32 mix-blend-multiply" />
                </div>
                <div className="text-center">
                    <p className="text-[10px] font-bold text-secondary uppercase tracking-[0.2em] mb-1">TU CÓDIGO</p>
                    <p className="font-medium text-sm text-primary">{appUser.email}</p>
                </div>
            </div>
            
            <h2 className="text-xl font-bold text-primary pl-2 mt-8">Niveles de Membresía</h2>
            <div className="space-y-4">
                {levels.map((level, idx) => {
                    const reached = points >= (level.min_points || 0);
                    return (
                        <div
                            key={idx}
                            className={`card-premium rounded-[24px] p-6 transition-all duration-500 ${reached ? 'border-[var(--accent)] shadow-[0_8px_30px_rgba(20,184,166,0.1)]' : 'opacity-50 grayscale'}`}
                        >
                            <div className="flex justify-between items-start mb-3">
                                <div>
                                    <h3 className="text-lg font-black uppercase tracking-wide" style={{color:level.color || '#14b8a6'}}>{level.name}</h3>
                                    <p className="text-xs text-secondary font-medium">{level.min_points || 0} Puntos</p>
                                </div>
                                {reached && <CheckCircle size={20} className="text-[var(--accent)]"/>}
                            </div>
                            <p className="text-sm text-primary opacity-80 leading-relaxed">{level.perks}</p>
                        </div>
                    );
                })}
            </div>
        </div>
    );
};

const UserTab = ({ appUser, theme, toggleTheme, installPrompt, onLogout, onDeleteAccount, onLogin, orders }) => {
    const isGuest = appUser?.isGuest;
    const avatarUrl = appUser?.photoURL;

    return (
        <div className="pt-20 px-6 pb-32 space-y-6">
            <div className="flex flex-col items-center text-center mb-8">
                <div className="w-24 h-24 rounded-full mb-4 shadow-2xl border-4 border-[var(--card-bg)] overflow-hidden relative">
                     {avatarUrl ? (
                        <img src={avatarUrl} className="w-full h-full object-cover" />
                    ) : (
                        <div className={`w-full h-full flex items-center justify-center text-3xl font-bold ${isGuest ? 'bg-[var(--input-bg)] text-secondary' : 'bg-gradient-to-tr from-teal-600 to-blue-600 text-white'}`}>
                            {isGuest ? <User size={32}/> : appUser.name?.charAt(0)}
                        </div>
                    )}
                </div>
                <h2 className="text-2xl font-bold text-primary">{appUser.name || 'Invitado'}</h2>
                <p className="text-secondary text-sm mt-1">{isGuest ? 'Explorando la app' : appUser.email}</p>
            </div>

            <div className="card-premium rounded-[24px] p-4 flex justify-between items-center">
                <div className="flex items-center gap-4">
                    <div className="w-10 h-10 rounded-full bg-[var(--input-bg)] flex items-center justify-center text-primary">
                        {theme === 'dark' ? <Moon size={18}/> : <Sun size={18}/>}
                    </div>
                    <div>
                        <h3 className="text-sm font-bold text-primary">Apariencia</h3>
                        <p className="text-[10px] text-secondary uppercase tracking-wider">{theme === 'dark' ? 'Oscuro' : 'Claro'}</p>
                    </div>
                </div>
                <button onClick={toggleTheme} className="bg-[var(--input-bg)] rounded-full px-4 py-2 text-xs font-bold text-primary border border-[var(--border-light)]">
                    Cambiar
                </button>
            </div>

            <div className="card-premium rounded-[24px] p-6 min-h-[200px]">
                <h3 className="text-lg font-bold mb-6 flex items-center gap-2 text-primary"><Receipt size={18} className="text-[var(--accent)]"/> Historial</h3>
                {isGuest && <p className="text-secondary text-sm text-center py-8">Inicia sesión para ver tu historial.</p>}
                {!isGuest && orders.length === 0 && <p className="text-secondary text-sm text-center py-8 opacity-60">Aún no tienes pedidos.</p>}
                {!isGuest && orders.map(order => (
                    <div key={order.id} className="border-b border-[var(--border-light)] py-4 last:border-0 text-sm">
                        <div className="flex justify-between font-bold text-primary mb-1">
                            <span>{order.title}</span>
                            <span>${Number(order.total).toFixed(2)}</span>
                        </div>
                        <div className="flex justify-between items-center">
                             <p className="text-xs text-secondary opacity-70">{new Date(order.date).toLocaleDateString()}</p>
                             <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${order.status==='processed'?'bg-green-500/10 text-green-500':'bg-yellow-500/10 text-yellow-500'}`}>{order.status}</span>
                        </div>
                    </div>
                ))}
            </div>

            <div className="space-y-3 pt-4">
                {isGuest ? (
                    <BouncyButton onClick={onLogin} className="w-full bg-[var(--text-primary)] text-[var(--bg-primary)] font-bold py-4 rounded-2xl shadow-lg">
                        Iniciar Sesión
                    </BouncyButton>
                ) : (
                    <BouncyButton onClick={onLogout} className="w-full bg-[var(--input-bg)] text-primary font-bold py-4 rounded-2xl flex items-center justify-center gap-2 border border-[var(--border-light)]">
                        <LogOut size={18}/> Cerrar Sesión
                    </BouncyButton>
                )}
            </div>

            {!isGuest && (
                <div className="pt-8 text-center">
                     <button onClick={() => {
                        if(window.confirm("¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer y perderás tus puntos.")) {
                            onDeleteAccount();
                        }
                     }} className="text-xs text-red-500/60 hover:text-red-500 transition-colors underline">
                        Eliminar mi cuenta y datos
                     </button>
                </div>
            )}
        </div>
    );
};

const ProductModal = ({ item, onClose, onAdd }) => {
    const [quantity, setQuantity] = useState(1);
    const [selectedModifiers, setSelectedModifiers] = useState([]);
    const [btnState, setBtnState] = useState('idle');
    
    if (!item) return null;
    
    const basePrice = item.pricing?.usd || 0;
    const modifiersCost = selectedModifiers.reduce((acc, mod) => acc + (mod.price || 0), 0);
    const unitPrice = basePrice + modifiersCost;
    const totalPrice = unitPrice * quantity;

    const toggleModifier = (modOption) => {
        const exists = selectedModifiers.find(m => m.name === modOption.name);
        if (exists) setSelectedModifiers(prev => prev.filter(m => m.name !== modOption.name));
        else setSelectedModifiers(prev => [...prev, modOption]);
    };
    
    const handleAdd = () => {
        if(btnState !== 'idle') return;
        setBtnState('loading');
        setTimeout(() => {
            setBtnState('success');
            if (navigator.vibrate) navigator.vibrate([50]);
            onAdd(item, quantity, selectedModifiers, totalPrice);
            setTimeout(() => onClose(), 800);
        }, 600);
    };

    return (
      <AnimatePresence>
        <div className="fixed inset-0 z-[80] flex items-end justify-center sm:items-center">
            <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="absolute inset-0 bg-black/60 backdrop-blur-md" onClick={onClose}/>
            <motion.div 
                initial={{ y: "100%" }} animate={{ y: 0 }} exit={{ y: "100%" }} 
                transition={{ type: "spring", damping: 25, stiffness: 300 }} 
                className="bg-[var(--card-bg)] w-full max-w-md h-[85vh] sm:h-auto sm:max-h-[85vh] rounded-t-[32px] sm:rounded-[32px] overflow-hidden relative z-10 flex flex-col shadow-2xl"
            >
                <div className="h-64 sm:h-72 relative flex-shrink-0 overflow-hidden bg-[var(--bg-secondary)]">
                   <motion.img 
                       src={item.image || FALLBACK_IMAGE} 
                       initial={{ scale: 1.2 }} animate={{ scale: 1 }} transition={{ duration: 0.8 }} 
                       className="w-full h-full object-cover" 
                       onError={(e)=>{e.target.onerror=null; e.target.src=FALLBACK_IMAGE}}
                   />
                   <div className="absolute inset-0 bg-gradient-to-t from-[var(--card-bg)] via-transparent to-transparent opacity-90"></div>
                   <button onClick={onClose} className="absolute top-6 right-6 bg-black/30 backdrop-blur-xl p-2 rounded-full text-white border border-white/10 z-20 hover:bg-black/50 transition"><X size={20}/></button>
                   <div className="absolute bottom-0 left-0 w-full p-8 pt-0">
                        <motion.h2 className="text-3xl font-bold text-primary mb-1 leading-none drop-shadow-md">{item.name}</motion.h2>
                        <p className="text-[var(--accent)] font-bold text-2xl mt-2">${unitPrice.toFixed(2)}</p>
                   </div>
                </div>
                
                <div className="px-8 py-6 flex-1 overflow-y-auto no-scrollbar bg-[var(--card-bg)]">
                    <p className="text-secondary text-[15px] leading-relaxed mb-8 font-medium opacity-90">{item.description || "Disfruta de nuestra selección especial."}</p>
                    {item.modifiers && item.modifiers.length > 0 && (
                        <div className="space-y-8 pb-8">
                           {item.modifiers.map((modGroup, idx) => (
                               <div key={idx} className="animate-fadeIn">
                                   <h3 className="text-xs font-bold text-secondary uppercase mb-3 tracking-widest ml-1 flex items-center gap-2 opacity-70">{modGroup.name}</h3>
                                   <div className="grid grid-cols-1 gap-2">
                                      {modGroup.options.map((opt, optIdx) => {
                                          const isSelected = selectedModifiers.some(m => m.name === opt.name);
                                          return (
                                            <BouncyButton key={optIdx} onClick={() => toggleModifier(opt)} className={`p-4 rounded-2xl text-left border transition-all duration-300 flex justify-between items-center ${isSelected ? 'bg-[var(--accent)] text-white border-transparent shadow-md' : 'bg-[var(--input-bg)] border-transparent text-primary'}`}>
                                                <span className="font-semibold text-sm">{opt.name}</span>
                                                <div className="flex items-center gap-2">
                                                    {opt.price > 0 && <span className={`text-xs ${isSelected?'text-white/90':'text-secondary'}`}>+${opt.price.toFixed(2)}</span>}
                                                    {isSelected && <CheckCircle size={16} className="text-white" />}
                                                </div>
                                            </BouncyButton>
                                          );
                                      })}
                                   </div>
                               </div>
                           ))}
                        </div>
                    )}
                </div>
                
                <div className="p-6 bg-[var(--card-bg)] border-t border-[var(--border-light)] flex items-center gap-4 safe-area-pb shadow-[0_-10px_40px_rgba(0,0,0,0.1)] z-20 relative">
                    <div className="flex items-center bg-[var(--input-bg)] rounded-full h-14 px-2">
                        <button onClick={() => setQuantity(Math.max(1, quantity - 1))} className="w-12 h-full flex items-center justify-center text-secondary hover:text-primary"><Minus size={20} /></button>
                        <span className="font-bold text-primary w-8 text-center text-lg">{quantity}</span>
                        <button onClick={() => setQuantity(quantity + 1)} className="w-12 h-full flex items-center justify-center text-secondary hover:text-primary"><Plus size={20} /></button>
                    </div>
                    <BouncyButton onClick={handleAdd} disabled={btnState !== 'idle'} className={`flex-1 h-14 rounded-full font-bold text-lg shadow-xl flex items-center justify-center transition-all relative ${btnState === 'success' ? 'bg-green-500 text-white' : 'bg-[var(--text-primary)] text-[var(--bg-primary)]'}`}>
                        {btnState === 'idle' && <span>Agregar &middot; ${totalPrice.toFixed(2)}</span>}
                        {btnState === 'loading' && <Loader className="animate-spin"/>}
                        {btnState === 'success' && <CheckCircle className="fill-current" size={28} />}
                    </BouncyButton>
                </div>
            </motion.div>
        </div>
      </AnimatePresence>
    );
};

const OrderSuccessModal = ({ orderId, onClose }) => (
    <div className="fixed inset-0 z-[90] flex items-center justify-center px-6">
        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="absolute inset-0 bg-black/80 backdrop-blur-sm" onClick={onClose}/>
        <motion.div initial={{ scale: 0.8, opacity: 0 }} animate={{ scale: 1, opacity: 1 }} className="bg-[var(--card-bg)] w-full max-w-sm rounded-[32px] p-8 text-center relative z-10 shadow-2xl border border-[var(--border-light)]">
            <div className="w-20 h-20 bg-[var(--accent)] rounded-full flex items-center justify-center mx-auto mb-6 shadow-lg shadow-teal-500/30"><CheckCircle size={40} className="text-white" /></div>
            <h2 className="text-2xl font-bold text-primary mb-2">¡Pedido Recibido!</h2>
            <p className="text-secondary mb-8 leading-relaxed">Tu orden <span className="text-primary font-bold">#{orderId}</span> ha sido enviada a la cocina.</p>
            <BouncyButton onClick={onClose} className="w-full bg-[var(--text-primary)] text-[var(--bg-primary)] font-bold py-4 rounded-[20px] shadow-lg">Entendido</BouncyButton>
        </motion.div>
    </div>
);

const CheckoutDrawer = ({ cart, user, onClose, onProcess, onUpdateQty, onRemoveItem }) => {
    const [step, setStep] = useState('cart');
    const [orderType, setOrderType] = useState('mesa');
    const [tableNumber, setTableNumber] = useState('');
    const [address, setAddress] = useState('');
    const [paymentMethod, setPaymentMethod] = useState('pago_movil');
    const [isProcessing, setIsProcessing] = useState(false);
    const [deliveryGeo, setDeliveryGeo] = useState(null);
    
    const total = cart.reduce((acc, i) => acc + (i.unitPrice * i.quantity), 0);
    const handleProcess = () => {
        if(isProcessing) return;
        setIsProcessing(true);
        onProcess({ items: cart, total, payment_method: paymentMethod, user, type: orderType, table: tableNumber, address, delivery_geo: deliveryGeo }, () => setIsProcessing(false));
    };

    useEffect(() => {
        if(orderType !== 'delivery') { setDeliveryGeo(null); return; }
        if(address && address !== 'Detectando ubicación...') return;
        if(!navigator.geolocation) return;
        
        setAddress('Detectando ubicación...');
        navigator.geolocation.getCurrentPosition(async (pos) => {
            try {
                const { latitude, longitude } = pos.coords;
                setDeliveryGeo({ lat: latitude, lng: longitude, map_url: `https://www.google.com/maps?q=${latitude},${longitude}` });
                const res = await fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${latitude}&lon=${longitude}`);
                const data = await res.json();
                if(data && data.display_name) {
                    setAddress(data.display_name.split(',').slice(0, 3).join(','));
                } else {
                    setAddress(`Ubicación GPS: ${latitude.toFixed(4)}, ${longitude.toFixed(4)}`);
                }
            } catch (e) { setAddress(''); setDeliveryGeo(null); }
        }, () => { setAddress(''); }, { enableHighAccuracy: true, timeout: 10000 });
    }, [orderType]);

    return (
        <div className="fixed inset-0 z-[70] flex justify-end">
            <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose}/>
            <motion.div initial={{ x: "100%" }} animate={{ x: 0 }} exit={{ x: "100%" }} className="w-full max-w-md bg-[var(--card-bg)] h-full relative z-10 shadow-2xl flex flex-col border-l border-[var(--border-light)]">
                <div className="p-6 pt-12 border-b border-[var(--border-light)] flex justify-between items-center">
                    <h2 className="text-2xl font-bold text-primary">{step==='cart'?'Tu Bolsa':'Checkout'}</h2>
                    <button onClick={onClose} className="text-secondary hover:text-primary bg-[var(--input-bg)] p-2 rounded-full transition-colors"><X size={20}/></button>
                </div>
                <div className="flex-1 overflow-y-auto p-6 space-y-4 no-scrollbar bg-[var(--bg-primary)]">
                   {step === 'cart' ? (
                        cart.length===0 ? <div className="text-center mt-32 opacity-50"><ShoppingBag size={64} className="mx-auto mb-6 text-[var(--accent)]"/><p className="text-secondary text-lg">Tu bolsa está vacía.</p></div> : cart.map(item => (
                            <motion.div 
                                key={item.uniqueId} 
                                layout
                                initial={{ opacity: 0, x: -20 }}
                                animate={{ opacity: 1, x: 0 }}
                                exit={{ opacity: 0, x: 100, transition: { duration: 0.2 } }}
                                drag="x"
                                dragConstraints={{ left: 0, right: 0 }}
                                dragElastic={{ left: 0.1, right: 0.6 }}
                                onDragEnd={(e, info) => {
                                    if(info.offset.x > 80) onRemoveItem(item.uniqueId);
                                }}
                                className="flex gap-4 bg-[var(--card-bg)] p-3 rounded-[20px] shadow-sm border border-[var(--border-light)] relative overflow-hidden touch-pan-y select-none"
                                style={{ touchAction: 'pan-y' }}
                            >
                                <div className="absolute inset-y-0 left-0 w-full bg-red-500/20 flex items-center justify-start pl-6 rounded-[20px] -z-10">
                                    <Trash2 className="text-red-500" size={24}/>
                                </div>
                                <img src={item.item?.image || item.image || FALLBACK_IMAGE} className="w-20 h-20 rounded-2xl bg-[var(--bg-secondary)] object-cover pointer-events-none select-none" onError={(e)=>{e.target.onerror=null; e.target.src=FALLBACK_IMAGE}}/>
                                <div className="flex-1 py-1 min-w-0 pointer-events-none select-none">
                                    <h4 className="text-primary font-bold leading-tight truncate">{item.name}</h4>
                                    <p className="text-xs text-secondary mt-1 mb-2 truncate">{item.modifiers?.map(m=>m.name).join(', ')}</p>
                                    <div className="flex justify-between items-center pointer-events-auto">
                                        <div className="flex items-center gap-3 bg-[var(--input-bg)] rounded-lg px-2 py-1" onPointerDownCapture={e => e.stopPropagation()}>
                                            <button onClick={()=>onUpdateQty(item.uniqueId, item.quantity-1)} className="text-secondary hover:text-primary"><Minus size={14}/></button>
                                            <span className="text-primary text-xs font-bold w-4 text-center">{item.quantity}</span>
                                            <button onClick={()=>onUpdateQty(item.uniqueId, item.quantity+1)} className="text-secondary hover:text-primary"><Plus size={14}/></button>
                                        </div>
                                        <span className="font-bold text-primary">${(item.unitPrice*item.quantity).toFixed(2)}</span>
                                    </div>
                                </div>
                            </motion.div>
                        ))
                   ) : (
                       <div className="space-y-5">
                           <div className="grid grid-cols-2 gap-3">
                                <button onClick={()=>setOrderType('mesa')} className={`p-4 rounded-2xl border transition-all ${orderType==='mesa'?'border-[var(--accent)] bg-[rgba(20,184,166,0.1)] text-[var(--accent)] shadow-lg':'border-transparent bg-[var(--input-bg)] text-secondary'}`}>
                                    <Store className="mx-auto mb-2"/> Mesa
                                </button>
                                <button onClick={()=>setOrderType('delivery')} className={`p-4 rounded-2xl border transition-all ${orderType==='delivery'?'border-[var(--accent)] bg-[rgba(20,184,166,0.1)] text-[var(--accent)] shadow-lg':'border-transparent bg-[var(--input-bg)] text-secondary'}`}>
                                    <Bike className="mx-auto mb-2"/> Delivery
                                </button>
                           </div>
                           {orderType==='mesa'?<input placeholder="# Número de Mesa" value={tableNumber} onChange={e=>setTableNumber(e.target.value)} className="input-premium w-full p-5 rounded-2xl outline-none font-medium text-lg"/>:<textarea placeholder="Dirección de entrega" value={address} onChange={e=>setAddress(e.target.value)} className="input-premium w-full p-5 rounded-2xl outline-none h-32 font-medium resize-none"/>}
                           <div className="relative">
                                <select value={paymentMethod} onChange={e=>setPaymentMethod(e.target.value)} className="input-premium w-full p-5 rounded-2xl outline-none appearance-none font-medium">
                                    <option value="pago_movil">Pago Móvil</option>
                                    <option value="zelle">Zelle</option>
                                    <option value="efectivo">Efectivo ($)</option>
                                </select>
                                <ChevronRight className="absolute right-5 top-1/2 -translate-y-1/2 text-secondary rotate-90 pointer-events-none" size={20}/>
                           </div>
                       </div>
                   )}
                </div>
                <div className="p-6 border-t border-[var(--border-light)] safe-area-pb bg-[var(--card-bg)] shadow-[0_-5px_30px_rgba(0,0,0,0.1)] z-20">
                    <div className="flex justify-between text-primary text-2xl font-black mb-5 tracking-tight"><span>Total</span><span>${total.toFixed(2)}</span></div>
                    {step==='cart' ? <BouncyButton onClick={()=>setStep('check')} disabled={cart.length===0} className="w-full bg-[var(--text-primary)] text-[var(--bg-primary)] h-16 rounded-[22px] font-bold text-xl shadow-xl">Continuar</BouncyButton> : <BouncyButton onClick={handleProcess} disabled={isProcessing} className="w-full bg-[var(--accent)] text-white h-16 rounded-[22px] font-bold text-xl shadow-xl">{isProcessing?<Loader className="animate-spin mx-auto"/>:'Confirmar Pedido'}</BouncyButton>}
                </div>
            </motion.div>
        </div>
    );
};

export default function EnigmaAppFinal() {
    const [authStep, setAuthStep] = useState('loading'); 
    const [activeTab, setActiveTab] = useState('home');
    const [searchQuery, setSearchQuery] = useState('');
    const [appUser, setAppUser] = useState(null);
    const [menuItems, setMenuItems] = useState([]);
    const [promos, setPromos] = useState([]);
    const [activeCategory, setActiveCategory] = useState('Todo');
    const [userStatus, setUserStatus] = useState({ points: 0, tier: { name: 'Miembro', min_points: 0, perks: '', next_level: null } });
    const [rewardsLevels, setRewardsLevels] = useState([]);
    const [orders, setOrders] = useState([]);
    const [theme, setTheme] = useState(() => localStorage.getItem('enigma_theme') || 'dark');
    const [cart, setCart] = useState(() => { 
        try { 
            const s = localStorage.getItem('enigma_cart'); 
            const parsed = s ? JSON.parse(s) : [];
            // Validación básica para evitar pantallas blancas por datos corruptos
            if(!Array.isArray(parsed)) return [];
            return parsed.filter(i => i && i.uniqueId && (i.item || i.name)); 
        } catch(e) { return []; } 
    });
    const [isCartOpen, setIsCartOpen] = useState(false);
    const [selectedItem, setSelectedItem] = useState(null);
    const [lastOrder, setLastOrder] = useState(null); 
    const [installPrompt, setInstallPrompt] = useState(null);
    const [showInstallBanner, setShowInstallBanner] = useState(false);
    const [isLoadingMenu, setIsLoadingMenu] = useState(true);
    const isGuestRef = useRef(false);
    const [isIOS, setIsIOS] = useState(false);

    useScrollToTop(activeTab);

    useEffect(() => { localStorage.setItem('enigma_cart', JSON.stringify(cart)); }, [cart]);
    useEffect(() => {
        document.body.dataset.theme = theme;
        localStorage.setItem('enigma_theme', theme);
    }, [theme]);
    useEffect(() => {
        if(appUser?.email && !appUser.isGuest) loadOrders(appUser.email);
        else setOrders([]);
    }, [appUser]);

    const categories = useMemo(() => {
        const uniqueCats = ['Todo'];
        if (menuItems.length > 0) menuItems.forEach(i => { if (!uniqueCats.includes(i.category_name || 'General')) uniqueCats.push(i.category_name || 'General'); });
        return uniqueCats;
    }, [menuItems]);

    const filteredItems = useMemo(() => {
        return menuItems.filter(item => (activeCategory === 'Todo' || item.category_name === activeCategory) && item.name.toLowerCase().includes(searchQuery.toLowerCase()));
    }, [menuItems, searchQuery, activeCategory]);

    useEffect(() => {
        // Detect iOS
        const isIosDevice = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
        const isStandalone = window.matchMedia('(display-mode: standalone)').matches || window.navigator.standalone;
        setIsIOS(isIosDevice);

        if ('serviceWorker' in navigator) {
            navigator.serviceWorker.register('./sw.js').catch(console.log);
        }
        
        window.addEventListener('beforeinstallprompt', (e) => { 
            e.preventDefault(); 
            setInstallPrompt(e); 
            if(!isStandalone) setShowInstallBanner(true); 
        });

        // Show banner on iOS if not installed
        if (isIosDevice && !isStandalone) {
            setShowInstallBanner(true);
        }

        if(MODO_PRUEBA_ACTIVO) {
             setAppUser({ name: 'Tester', email: 'test@enigma.com' }); setAuthStep('app'); setIsLoadingMenu(false);
             return;
        }
        
        const unsub = onAuthStateChanged(auth, u => {
            if(u) {
                isGuestRef.current = false;
                setAppUser({ id: u.uid, name: u.displayName, email: u.email, photoURL: u.photoURL, isGuest: false });
                setAuthStep('app');
                fetch(`${API_BASE_URL}/user_status?email=${encodeURIComponent(u.email)}&t=${Date.now()}`)
                    .then(r=>r.json())
                    .then(d => { if(d.status==='success') setUserStatus({ points: d.loyalty.total_points, tier: d.loyalty.tier }); });
                loadOrders(u.email);
            } else {
                if (!isGuestRef.current) setAuthStep('login');
            }
        });

        Promise.all([
            fetch(`${API_BASE_URL}/menu?t=${Date.now()}`).then(r=>r.json()),
            fetch(`${API_BASE_URL}/promos?t=${Date.now()}`).then(r=>r.json()),
            fetch(`${API_BASE_URL}/rewards?t=${Date.now()}`).then(r=>r.json())
        ]).then(([menu, promoData, rewardsData]) => {
            if(Array.isArray(menu)) setMenuItems(menu);
            if(Array.isArray(promoData)) setPromos(promoData);
            if(rewardsData?.status === 'success') setRewardsLevels(rewardsData.levels || []);
            setIsLoadingMenu(false);
        });
        
        return () => unsub();
    }, []);

    const loadOrders = (email) => {
        fetch(`${API_BASE_URL}/orders?email=${encodeURIComponent(email)}&t=${Date.now()}`)
            .then(r=>r.json())
            .then(d => { if(d.status==='success') setOrders(d.orders || []); });
    };

    const handleLogin = async () => { try { await signInWithPopup(auth, new GoogleAuthProvider()); } catch(e) { alert('Error login'); } };
    const handleGuestLogin = () => { isGuestRef.current = true; setAppUser({ id: 'guest', name: 'Invitado', email: '', isGuest: true }); setOrders([]); setAuthStep('app'); };
    const handleLogout = () => { signOut(auth); setAppUser(null); setOrders([]); setAuthStep('login'); };
    const handleDeleteAccount = async () => {
        try {
            const current = auth.currentUser;
            if(!current) return alert('Reinicia sesión para eliminar tu cuenta.');
            await deleteUser(current);
            alert('Cuenta eliminada correctamente.');
            setAppUser(null);
            setOrders([]);
            setAuthStep('login');
        } catch (e) { alert('No pudimos eliminar la cuenta. Intenta cerrar sesión y volver a entrar.'); }
    };
    const toggleTheme = () => setTheme(prev => prev === 'dark' ? 'light' : 'dark');
    
    const addToCart = (item, qty, mods, total) => { setCart([...cart, { uniqueId: Date.now(), item, name: item.name, unitPrice: total/qty, quantity: qty, modifiers: mods }]); setSelectedItem(null); };
    const updateCartItem = (id, qty) => {
        if(qty <= 0) return removeCartItem(id);
        setCart(prev => prev.map(item => item.uniqueId === id ? { ...item, quantity: qty } : item));
    };
    const removeCartItem = (id) => setCart(prev => prev.filter(item => item.uniqueId !== id));
    
    const processOrder = async (orderData, onComplete) => {
        try {
            const response = await fetch(`${API_BASE_URL}/order`, {
                method: 'POST', headers: {'Content-Type':'application/json'},
                body: JSON.stringify({ ...orderData, user: appUser })
            });
            const result = await response.json();
            if(result.status === 'success') {
                setCart([]); setIsCartOpen(false);
                if(orderData.type === 'delivery') {
                    let msg = `*PEDIDO ENIGMA #${result.order_id}* ☕\n\n👤 *${appUser.name}*\n📍 *${orderData.address}*\n💳 ${orderData.payment_method}\n\n*ORDEN:*`;
                    orderData.items.forEach(i => { msg += `\n${i.quantity}x ${i.name}`; if(i.modifiers?.length) msg += ` _(${i.modifiers.map(m => m.name).join(', ')})_`; });
                    msg += `\n\n💰 *Total:* $${orderData.total.toFixed(2)}`;
                    setTimeout(() => { window.open(`https://wa.me/${WHATSAPP_NUMBER}?text=${encodeURIComponent(msg)}`, '_blank'); }, 500);
                } else setLastOrder(result.order_id || result.order_ref);
            } else alert('Error al procesar');
        } catch(e) { alert('Error de conexión'); } finally { if(onComplete) onComplete(); }
    };

    const handleInstall = () => {
        if(installPrompt) {
            installPrompt.prompt();
            installPrompt.userChoice.then(() => setShowInstallBanner(false));
        }
    };

    if(authStep === 'login') {
        return (
            <AppContainer theme={theme}>
                <div className="flex flex-col items-center justify-center h-screen p-6 relative overflow-hidden bg-black">
                    <div className="absolute top-[-20%] left-[-20%] w-[80%] h-[80%] bg-teal-500/10 rounded-full blur-[120px] animate-pulse"/>
                    <div className="w-40 h-40 bg-zinc-900/80 backdrop-blur-xl border border-white/10 rounded-[32px] flex items-center justify-center mb-8 shadow-2xl relative z-10"><img src={LOGO_DARK} className="w-28 opacity-100"/></div>
                    <h1 className="text-4xl font-bold text-white mb-2 tracking-tight relative z-10">Enigma Café</h1>
                    <p className="text-teal-200/60 text-sm mb-12 tracking-[0.3em] uppercase relative z-10 font-bold">¿Te atreves?</p>
                    <div className="w-full max-w-sm flex flex-col gap-4 relative z-10">
                        <BouncyButton onClick={handleLogin} className="w-full bg-white text-black font-bold py-4 rounded-[20px] flex justify-center gap-3 shadow-xl items-center"><span className="font-black text-teal-600 text-lg">G</span> Continuar con Google</BouncyButton>
                        <button onClick={handleGuestLogin} className="w-full py-3 text-zinc-500 text-sm font-medium hover:text-white transition-colors flex items-center justify-center gap-2">Solo quiero ver el menú <ArrowRight size={14}/></button>
                    </div>
                </div>
            </AppContainer>
        );
    }

    if(authStep === 'loading') return <div className="min-h-screen bg-black flex items-center justify-center text-teal-500"><Loader className="animate-spin"/></div>;

    return (
        <AppContainer theme={theme}>
            <AnimatePresence>{selectedItem && <ProductModal item={selectedItem} onClose={() => setSelectedItem(null)} onAdd={addToCart} />}</AnimatePresence>
            <AnimatePresence>{isCartOpen && <CheckoutDrawer cart={cart} user={appUser} onClose={() => setIsCartOpen(false)} onProcess={processOrder} onUpdateQty={updateCartItem} onRemoveItem={removeCartItem} />}</AnimatePresence>
            <AnimatePresence>{lastOrder && <OrderSuccessModal orderId={lastOrder} onClose={() => setLastOrder(null)} />}</AnimatePresence>
            <AnimatePresence>{showInstallBanner && <InstallBanner onInstall={handleInstall} onClose={() => setShowInstallBanner(false)} isIOS={isIOS} />}</AnimatePresence>

            <div className="fixed bottom-6 left-1/2 -translate-x-1/2 z-50 w-full max-w-[350px]">
                <GlassBlur className="rounded-[32px] p-2 px-6 flex items-center justify-between shadow-2xl">
                    {[
                        { id: 'home', icon: Home, label: 'Inicio' },
                        { id: 'menu', icon: Coffee, label: 'Menú' },
                        { id: 'rewards', icon: Gift, label: 'Rewards' },
                        { id: 'user', icon: User, label: 'Perfil' }
                    ].map(tab => (
                        <button key={tab.id} onClick={() => setActiveTab(tab.id)} className={`relative p-2 flex flex-col items-center gap-1 transition-all duration-300 ${activeTab === tab.id ? 'text-primary -translate-y-1' : 'text-secondary hover:text-primary'}`}>
                            <tab.icon size={24} strokeWidth={activeTab === tab.id ? 2.5 : 2} />
                            {activeTab === tab.id && <motion.div layoutId="dot" className="absolute -bottom-2 w-1 h-1 bg-[var(--accent)] rounded-full shadow-[0_0_10px_currentColor]" />}
                        </button>
                    ))}
                </GlassBlur>
            </div>

            <AnimatePresence>
                {cart.length > 0 && !isCartOpen && (
                    <motion.button 
                        initial={{scale:0}} animate={{scale:1}} exit={{scale:0}}
                        whileHover={{ scale: 1.05 }}
                        whileTap={{ scale: 0.95 }}
                        onClick={() => setIsCartOpen(true)} 
                        className="fixed bottom-28 right-6 z-50 bg-[var(--text-primary)] text-[var(--bg-primary)] w-16 h-16 rounded-full flex items-center justify-center shadow-[0_10px_30px_-10px_rgba(0,0,0,0.5),0_0_20px_rgba(20,184,166,0.5)] border-2 border-[var(--bg-primary)]"
                    >
                        <ShoppingBag size={26} />
                        <span className="absolute -top-1 -right-1 bg-red-500 text-white text-[10px] w-6 h-6 flex items-center justify-center rounded-full border-4 border-[var(--bg-primary)] font-bold">{cart.length}</span>
                    </motion.button>
                )}
            </AnimatePresence>

            <div className="pb-24">
                {activeTab === 'home' && <HomeTab user={appUser} userStatus={userStatus} promos={promos} rewardsLevels={rewardsLevels} theme={theme} />}
                {activeTab === 'menu' && <MenuTab items={filteredItems} categories={categories} activeCategory={activeCategory} setActiveCategory={setActiveCategory} onItemClick={setSelectedItem} searchQuery={searchQuery} setSearchQuery={setSearchQuery} isLoading={isLoadingMenu} theme={theme} />}
                {activeTab === 'rewards' && <RewardsTab appUser={appUser} rewardsLevels={rewardsLevels} userStatus={userStatus} onLogin={handleLogin} theme={theme} />}
                {activeTab === 'user' && <UserTab appUser={appUser} theme={theme} toggleTheme={toggleTheme} installPrompt={installPrompt} onLogout={handleLogout} onDeleteAccount={handleDeleteAccount} onLogin={handleLogin} orders={orders} />}
            </div>
        </AppContainer>
    );
}
