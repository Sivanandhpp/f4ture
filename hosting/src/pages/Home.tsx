import { motion, useScroll, useTransform } from 'framer-motion';
import { Calendar, CheckCircle2, Users, MessageCircle, ShieldCheck, Zap, Download, ExternalLink, ArrowRight } from 'lucide-react';
import { Link } from 'react-router-dom';
import { APP_CONFIG } from '../config';
import { useRef } from 'react';

export default function Home() {
    const targetRef = useRef<HTMLDivElement>(null);
    const { scrollYProgress } = useScroll({
        target: targetRef,
        offset: ["start start", "end start"]
    });

    const opacity = useTransform(scrollYProgress, [0, 0.5], [1, 0]);
    const scale = useTransform(scrollYProgress, [0, 0.5], [1, 0.9]);
    const y = useTransform(scrollYProgress, [0, 0.5], [0, 50]);

    const container = {
        hidden: { opacity: 0 },
        show: {
            opacity: 1,
            transition: {
                staggerChildren: 0.1,
                delayChildren: 0.3
            }
        }
    };

    return (
        <div className="relative min-h-screen text-white selection:bg-primary/30">
            {/* Fluid Background */}
            <div className="fixed inset-0 z-0 overflow-hidden pointer-events-none">
                <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-primary/20 rounded-full blur-[120px] animate-pulse" style={{ animationDuration: '8s' }} />
                <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] bg-purple-500/20 rounded-full blur-[120px] animate-pulse" style={{ animationDuration: '10s' }} />
                <div className="absolute top-[40%] left-[80%] w-[30%] h-[30%] bg-blue-500/10 rounded-full blur-[100px] animate-pulse" style={{ animationDuration: '12s' }} />
            </div>

            <div className="relative z-10 space-y-32 pb-20">
                {/* Hero Section */}
                <section ref={targetRef} className="relative pt-20 pb-12 min-h-[85vh] flex flex-col items-center justify-center text-center px-4">
                    <motion.div
                        style={{ opacity, scale, y }}
                        className="max-w-5xl mx-auto"
                    >
                        <motion.div
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ duration: 0.6, ease: "easeOut" }}
                            className="inline-flex items-center gap-2 mb-6 px-4 py-1.5 rounded-full border border-primary/20 bg-primary/5 text-primary text-sm font-bold tracking-widest uppercase backdrop-blur-sm"
                        >
                            <span className="relative flex h-2 w-2">
                                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary opacity-75"></span>
                                <span className="relative inline-flex rounded-full h-2 w-2 bg-primary"></span>
                            </span>
                            Jan 29 – Feb 1, 2026
                        </motion.div>

                        <motion.h1
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ duration: 0.8, delay: 0.1, ease: "easeOut" }}
                            className="text-5xl md:text-8xl font-black tracking-tighter mb-6 leading-[0.95] uppercase"
                        >
                            Where The <br />
                            <span className="text-transparent bg-clip-text bg-gradient-to-r from-primary via-white to-purple-400 animate-gradient-x">
                                Future Comes Alive
                            </span>
                        </motion.h1>

                        <motion.p
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ duration: 0.8, delay: 0.2, ease: "easeOut" }}
                            className="text-lg md:text-2xl text-zinc-300 mb-10 max-w-3xl mx-auto leading-relaxed font-light"
                        >
                            India’s Biggest Futuristic & Vibrant Festival returns, where ideas ignite, innovations take shape, and the world meets tomorrow.
                        </motion.p>

                        <motion.div
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ duration: 0.8, delay: 0.3, ease: "easeOut" }}
                            className="flex flex-col sm:flex-row gap-4 justify-center items-center w-full"
                        >
                            {/* Primary Button: Download App */}
                            <a
                                href="/app-release.apk"
                                download="F4ture-App.apk"
                                className="group relative px-8 py-4 bg-primary text-black font-bold rounded-full text-lg shadow-[0_0_30px_rgba(0,229,255,0.3)] hover:shadow-[0_0_50px_rgba(0,229,255,0.5)] hover:scale-105 transition-all duration-300 w-full sm:w-auto flex items-center justify-center gap-3 overflow-hidden"
                            >
                                <div className="absolute inset-0 bg-white/20 translate-y-full group-hover:translate-y-0 transition-transform duration-300" />
                                <Download size={22} className="relative z-10" />
                                <span className="relative z-10">Download App</span>
                            </a>

                            {/* Secondary Button: Visit Website */}
                            <a
                                href={APP_CONFIG.futureSummitUrl}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="group px-8 py-4 bg-zinc-900/60 border border-white/10 hover:border-primary/50 hover:bg-zinc-800 rounded-full text-lg font-medium text-white transition-all duration-300 w-full sm:w-auto flex items-center justify-center gap-3 backdrop-blur-md"
                            >
                                <span>Visit Official Website</span>
                                <ExternalLink size={20} className="group-hover:translate-x-1 group-hover:-translate-y-1 transition-transform" />
                            </a>
                        </motion.div>

                        <motion.div
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            transition={{ duration: 1, delay: 1 }}
                            className="mt-6 text-sm text-zinc-500"
                        >
                            <Link to="/privacy-policy" className="hover:text-zinc-300 transition-colors underline underline-offset-4">Privacy Policy</Link>
                        </motion.div>
                    </motion.div>
                </section>

                {/* Features Grid */}
                <section className="px-4 max-w-7xl mx-auto">
                    <motion.div
                        variants={container}
                        initial="hidden"
                        whileInView="show"
                        viewport={{ once: true, margin: "-100px" }}
                    >
                        <div className="text-center mb-16">
                            <h2 className="text-3xl md:text-5xl font-bold mb-4">Everything you need</h2>
                            <p className="text-zinc-400 text-lg">Powerful features wrapped in a stunning design.</p>
                        </div>

                        <div className="grid md:grid-cols-3 gap-6">
                            <FeatureCard
                                icon={<Calendar size={32} className="text-purple-400" />}
                                title="Event Management"
                                desc="Create, discover, and manage campus events with seamless ticketing and scheduling."
                                delay={0}
                            />
                            <FeatureCard
                                icon={<CheckCircle2 size={32} className="text-emerald-400" />}
                                title="Task Tracking"
                                desc="Stay on top of deadlines with shared task lists, assignees, and real-time status updates."
                                delay={0.1}
                            />
                            <FeatureCard
                                icon={<Users size={32} className="text-blue-400" />}
                                title="Community Groups"
                                desc="Join committees and clubs. Collaborate in private groups with focused discussions."
                                delay={0.2}
                            />
                            <FeatureCard
                                icon={<MessageCircle size={32} className="text-pink-400" />}
                                title="Real-time Chat"
                                desc="Instant messaging for your groups and events. Never miss an important update."
                                delay={0.3}
                            />
                            <FeatureCard
                                icon={<ShieldCheck size={32} className="text-orange-400" />}
                                title="Secure & Private"
                                desc="Your data is protected. Use anonymous reporting and secure authentication."
                                delay={0.4}
                            />
                            <FeatureCard
                                icon={<Zap size={32} className="text-yellow-400" />}
                                title="Fast & Fluid"
                                desc="A futuristic UI designed for speed and ease of use, powered by the latest tech."
                                delay={0.5}
                            />
                        </div>
                    </motion.div>
                </section>

                {/* Call to Action Footer */}
                <section className="px-4 pb-20">
                    <div className="max-w-5xl mx-auto bg-gradient-to-br from-zinc-900 via-black to-zinc-900 border border-white/10 rounded-[2.5rem] p-12 md:p-20 text-center relative overflow-hidden group">
                        {/* Animated grid background */}
                        <div className="absolute inset-0 bg-[url('https://grainy-gradients.vercel.app/noise.svg')] opacity-20 brightness-100 contrast-150 mix-blend-overlay pointer-events-none"></div>
                        <div className="absolute -top-[50%] -left-[50%] w-[200%] h-[200%] bg-[radial-gradient(circle_at_center,_var(--tw-gradient-stops))] from-primary/10 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-1000" />

                        <div className="relative z-10 max-w-2xl mx-auto">
                            <h2 className="text-4xl md:text-5xl font-bold mb-6 tracking-tight">Ready to dive in?</h2>
                            <p className="text-zinc-400 text-lg mb-10">
                                Join thousands of students and organizers transforming how they manage campus life.
                            </p>
                            <a
                                href="/app-release.apk"
                                download
                                className="inline-flex items-center gap-2 text-primary hover:text-cyan-300 font-bold text-xl hover:scale-110 transition-transform duration-300"
                            >
                                Get the App Now <ArrowRight size={24} />
                            </a>
                        </div>
                    </div>
                </section>
            </div>
        </div>
    );
}

function FeatureCard({ icon, title, desc, delay }: { icon: any, title: string, desc: string, delay: number }) {
    const item = {
        hidden: { opacity: 0, y: 30 },
        show: { opacity: 1, y: 0 }
    };

    return (
        <motion.div
            variants={item}
            whileHover={{ y: -10, transition: { duration: 0.2 } }}
            className="group p-8 rounded-3xl bg-zinc-900/40 border border-white/5 hover:border-primary/30 hover:bg-zinc-900/80 transition-all duration-300 backdrop-blur-sm relative overflow-hidden"
        >
            <div className="absolute inset-0 bg-gradient-to-br from-primary/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />

            <div className="relative z-10 mb-6 p-4 bg-zinc-950/50 rounded-2xl inline-block border border-white/5 group-hover:scale-110 transition-transform duration-300 shadow-xl">
                {icon}
            </div>
            <h3 className="relative z-10 text-xl font-bold mb-3 group-hover:text-primary transition-colors">{title}</h3>
            <p className="relative z-10 text-zinc-400 leading-relaxed font-light group-hover:text-zinc-300 transition-colors">
                {desc}
            </p>
        </motion.div>
    );
}
