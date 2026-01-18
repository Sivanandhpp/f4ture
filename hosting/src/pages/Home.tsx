import { motion } from 'framer-motion';
import { Calendar, CheckCircle2, Users, MessageCircle, ShieldCheck, Zap, ArrowRight } from 'lucide-react';
import { Link } from 'react-router-dom';
import { APP_CONFIG } from '../config';

export default function Home() {
    const container = {
        hidden: { opacity: 0 },
        show: {
            opacity: 1,
            transition: {
                staggerChildren: 0.1
            }
        }
    };



    return (
        <div className="space-y-32">
            {/* Hero Section */}
            <section className="relative pt-20 pb-32 flex flex-col items-center text-center">
                {/* Abstract Background Elements */}
                <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-primary/20 rounded-full blur-[120px] pointer-events-none" />

                <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.6 }}
                    className="relative z-10 max-w-3xl"
                >
                    <div className="inline-block mb-6 px-4 py-1.5 rounded-full border border-primary/30 bg-primary/10 text-primary text-sm font-semibold tracking-wide uppercase">
                        The Future of Campus Life
                    </div>
                    <h1 className="text-5xl md:text-7xl font-extrabold tracking-tight mb-8 leading-tight">
                        Connect. Organize. <br />
                        <span className="text-transparent bg-clip-text bg-gradient-to-r from-primary to-purple-400">
                            Thrive Together.
                        </span>
                    </h1>
                    <p className="text-lg md:text-xl text-zinc-400 mb-6 max-w-2xl mx-auto leading-relaxed">
                        {APP_CONFIG.name} is your all-in-one platform for managing campus events, collaborating on tasks, and staying connected with your community groups.
                    </p>

                    <a
                        href={APP_CONFIG.futureSummitUrl}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex items-center gap-2 text-primary hover:text-cyan-300 font-medium mb-10 hover:underline underline-offset-4 transition-all"
                    >
                        Know more about the Summit of Future <ArrowRight size={16} />
                    </a>

                    <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
                        <a
                            href={APP_CONFIG.playStoreUrl}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="px-8 py-4 bg-primary text-black font-bold rounded-full text-lg shadow-[0_0_40px_rgba(0,229,255,0.3)] hover:shadow-[0_0_60px_rgba(0,229,255,0.5)] hover:scale-105 transition-all w-full sm:w-auto"
                        >
                            Download for Android
                        </a>
                        <Link
                            to="/privacy-policy"
                            className="px-8 py-4 bg-zinc-900 border border-white/10 hover:bg-zinc-800 rounded-full text-lg font-medium transition-colors w-full sm:w-auto"
                        >
                            View Privacy Policy
                        </Link>
                    </div>
                </motion.div>
            </section>

            {/* Features Grid */}
            <motion.section
                variants={container}
                initial="hidden"
                whileInView="show"
                viewport={{ once: true, margin: "-100px" }}
                className="grid md:grid-cols-3 gap-8"
            >
                <FeatureCard
                    icon={<Calendar size={32} className="text-purple-400" />}
                    title="Event Management"
                    desc="Create, discover, and manage campus events with seamless ticketing and scheduling."
                />
                <FeatureCard
                    icon={<CheckCircle2 size={32} className="text-emerald-400" />}
                    title="Task Tracking"
                    desc="Stay on top of deadlines with shared task lists, assignees, and real-time status updates."
                />
                <FeatureCard
                    icon={<Users size={32} className="text-blue-400" />}
                    title="Community Groups"
                    desc="Join committees and clubs. Collaborate in private groups with focused discussions."
                />
                <FeatureCard
                    icon={<MessageCircle size={32} className="text-pink-400" />}
                    title="Real-time Chat"
                    desc="Instant messaging for your groups and events. Never miss an important update."
                />
                <FeatureCard
                    icon={<ShieldCheck size={32} className="text-orange-400" />}
                    title="Secure & Private"
                    desc="Your data is protected. Use anonymous reporting and secure authentication."
                />
                <FeatureCard
                    icon={<Zap size={32} className="text-yellow-400" />}
                    title="Fast & Fluid"
                    desc="A futuristic UI designed for speed and ease of use, powered by the latest tech."
                />
            </motion.section>

            {/* Call to Action */}
            <section className="bg-gradient-to-br from-zinc-900 to-black border border-white/10 rounded-3xl p-12 text-center relative overflow-hidden">
                <div className="absolute inset-0 bg-primary/5 pattern-grid-lg opacity-20" />
                <div className="relative z-10 max-w-2xl mx-auto">
                    <h2 className="text-3xl md:text-4xl font-bold mb-6">Ready to get started?</h2>
                    <p className="text-zinc-400 mb-8">
                        Join thousands of students and organizers transforming how they manage campus life.
                    </p>
                    <a
                        href={APP_CONFIG.playStoreUrl}
                        className="inline-flex items-center gap-2 text-primary hover:text-cyan-300 font-bold text-lg hover:underline underline-offset-4 transition-all"
                    >
                        Get the App on Play Store →
                    </a>
                </div>
            </section>
        </div>
    );
}

function FeatureCard({ icon, title, desc }: { icon: any, title: string, desc: string }) {
    const item = {
        hidden: { opacity: 0, y: 20 },
        show: { opacity: 1, y: 0 }
    };

    return (
        <motion.div variants={item} className="p-8 rounded-2xl bg-zinc-900/50 border border-white/5 hover:border-white/10 hover:bg-zinc-900 transition-colors">
            <div className="mb-4 p-3 bg-zinc-950 rounded-xl inline-block border border-white/5">
                {icon}
            </div>
            <h3 className="text-xl font-bold mb-3">{title}</h3>
            <p className="text-zinc-400 leading-relaxed">
                {desc}
            </p>
        </motion.div>
    );
}
