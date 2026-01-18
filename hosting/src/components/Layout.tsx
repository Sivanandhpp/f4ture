import { Link, Outlet, useLocation } from 'react-router-dom';
import { Menu, X, ExternalLink } from 'lucide-react';
import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import clsx from 'clsx';

export default function Layout() {
    const [isMenuOpen, setIsMenuOpen] = useState(false);
    const location = useLocation();

    const navLinks = [
        { name: 'Home', path: '/' },
        { name: 'Privacy Policy', path: '/privacy-policy' },
        { name: 'Terms & Conditions', path: '/terms-and-conditions' },
        { name: 'Support', path: '/support' },
    ];

    return (
        <div className="min-h-screen flex flex-col bg-background text-zinc-100 font-sans selection:bg-primary selection:text-black">
            {/* Header */}
            <header className="fixed top-0 left-0 right-0 z-50 bg-background/80 backdrop-blur-md border-b border-white/5">
                <div className="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
                    {/* Logo */}
                    <Link to="/" className="flex items-center gap-3 group">
                        <div className="relative w-10 h-10 overflow-hidden rounded-xl border border-white/10 group-hover:border-primary/50 transition-colors">
                            <img
                                src="/logo.png"
                                alt="Vishayam Logo"
                                className="w-full h-full object-cover"
                            />
                        </div>
                        <span className="text-xl font-bold tracking-tight bg-gradient-to-r from-white to-zinc-400 bg-clip-text text-transparent group-hover:from-primary group-hover:to-cyan-400 transition-all duration-300">
                            Vishayam
                        </span>
                    </Link>

                    {/* Desktop Nav */}
                    <nav className="hidden md:flex items-center gap-8">
                        {navLinks.map((link) => (
                            <Link
                                key={link.path}
                                to={link.path}
                                className={clsx(
                                    "text-sm font-medium transition-colors hover:text-primary",
                                    location.pathname === link.path ? "text-primary" : "text-zinc-400"
                                )}
                            >
                                {link.name}
                            </Link>
                        ))}
                        <a
                            href="https://play.google.com/store/apps/details?id=com.siva.vishayam"
                            target="_blank"
                            rel="noopener noreferrer"
                            className="px-5 py-2.5 bg-primary text-black font-semibold rounded-full hover:bg-cyan-300 hover:shadow-[0_0_20px_rgba(0,229,255,0.4)] transition-all flex items-center gap-2 transform hover:scale-105 active:scale-95"
                        >
                            Get App <ExternalLink size={16} />
                        </a>
                    </nav>

                    {/* Mobile Menu Button */}
                    <button
                        className="md:hidden p-2 text-zinc-400 hover:text-white"
                        onClick={() => setIsMenuOpen(!isMenuOpen)}
                    >
                        {isMenuOpen ? <X size={24} /> : <Menu size={24} />}
                    </button>
                </div>
            </header>

            {/* Mobile Nav Overlay */}
            <AnimatePresence>
                {isMenuOpen && (
                    <motion.div
                        initial={{ opacity: 0, y: -20 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: -20 }}
                        className="fixed inset-0 top-20 z-40 bg-zinc-950/95 backdrop-blur-xl md:hidden flex flex-col p-6 border-t border-white/10"
                    >
                        <div className="flex flex-col gap-6">
                            {navLinks.map((link) => (
                                <Link
                                    key={link.path}
                                    to={link.path}
                                    onClick={() => setIsMenuOpen(false)}
                                    className={clsx(
                                        "text-lg font-medium transition-colors",
                                        location.pathname === link.path ? "text-primary" : "text-zinc-400"
                                    )}
                                >
                                    {link.name}
                                </Link>
                            ))}
                            <hr className="border-white/10" />
                            <a
                                href="https://play.google.com/store/apps/details?id=com.siva.vishayam"
                                target="_blank"
                                rel="noopener noreferrer"
                                className="w-full py-4 bg-primary text-black font-bold text-center rounded-xl hover:bg-cyan-300 transition-colors"
                            >
                                Download App
                            </a>
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>

            {/* Main Content */}
            <main className="flex-1 pt-24 pb-12 px-6">
                <div className="max-w-4xl mx-auto">
                    <Outlet />
                </div>
            </main>

            {/* Footer */}
            <footer className="border-t border-white/5 bg-zinc-900/50 py-12 px-6 mt-auto">
                <div className="max-w-7xl mx-auto grid md:grid-cols-4 gap-8">
                    <div className="col-span-1 md:col-span-1">
                        <Link to="/" className="flex items-center gap-2 mb-4">
                            <img src="/logo.png" alt="Logo" className="w-8 h-8 rounded-lg" />
                            <span className="font-bold text-lg">Vishayam</span>
                        </Link>
                        <p className="text-zinc-500 text-sm leading-relaxed">
                            Empowering communities with seamless event management, task tracking, and real-time collaboration. The Future of Campus Life.
                        </p>
                    </div>

                    <div>
                        <h4 className="text-white font-semibold mb-4">Legal</h4>
                        <ul className="space-y-2 text-sm text-zinc-400">
                            <li><Link to="/privacy-policy" className="hover:text-primary transition-colors">Privacy Policy</Link></li>
                            <li><Link to="/terms-and-conditions" className="hover:text-primary transition-colors">Terms & Conditions</Link></li>
                        </ul>
                    </div>

                    <div>
                        <h4 className="text-white font-semibold mb-4">Support</h4>
                        <ul className="space-y-2 text-sm text-zinc-400">
                            <li><Link to="/support" className="hover:text-primary transition-colors">Help Center</Link></li>
                            <li><Link to="/support#contact" className="hover:text-primary transition-colors">Contact Us</Link></li>
                            <li><a href="mailto:sivanandhpp@gmail.com" className="hover:text-primary transition-colors">sivanandhpp@gmail.com</a></li>
                        </ul>
                    </div>

                    <div>
                        <h4 className="text-white font-semibold mb-4">Get the App</h4>
                        <div className="flex flex-col gap-3">
                            <a href="#" className="block w-36 opacity-50 hover:opacity-100 cursor-not-allowed transition-opacity">
                                {/* Placeholder for App Store Badge */}
                                <div className="h-10 bg-zinc-800 rounded-lg border border-white/10 flex items-center justify-center text-xs text-zinc-400">
                                    App Store (Coming Soon)
                                </div>
                            </a>
                            <a href="https://play.google.com/store/apps/details?id=com.siva.vishayam" className="block w-36 hover:opacity-80 transition-opacity">
                                {/* Generic Google Play Styled Badge */}
                                <div className="h-10 bg-white text-black rounded-lg border border-white/10 flex items-center justify-center font-bold text-xs gap-2">
                                    <img src="https://upload.wikimedia.org/wikipedia/commons/d/d0/Google_Play_Arrow_logo.svg" className="w-4 h-4" alt="" />
                                    Google Play
                                </div>
                            </a>
                        </div>
                    </div>
                </div>
                <div className="max-w-7xl mx-auto mt-12 pt-8 border-t border-white/5 text-center text-zinc-600 text-sm">
                    © {new Date().getFullYear()} Vishayam. All rights reserved.
                </div>
            </footer>
        </div>
    );
}
