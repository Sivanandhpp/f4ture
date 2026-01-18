import { Mail, HelpCircle, FileQuestion } from 'lucide-react';
import { APP_CONFIG } from '../config';

export default function Support() {
    return (
        <div className="max-w-3xl mx-auto py-12">
            <h1 className="text-4xl font-bold mb-8 flex items-center gap-3">
                <HelpCircle className="text-primary" size={36} />
                Help & Support
            </h1>

            <p className="text-xl text-zinc-400 mb-12">
                Need help with {APP_CONFIG.name}? Find answers to common questions or get in touch with our team.
            </p>

            {/* Contact Section */}
            <section id="contact" className="mb-16">
                <div className="bg-zinc-900/50 border border-white/10 rounded-2xl p-8 flex flex-col md:flex-row items-center gap-8">
                    <div className="flex-1">
                        <h2 className="text-2xl font-bold mb-4 flex items-center gap-2">
                            <Mail className="text-primary" /> Contact Us
                        </h2>
                        <p className="text-zinc-400 mb-6">
                            If you have any issues with your account, reporting content, or feature suggestions, please email us directly. We aim to respond within 24-48 hours.
                        </p>
                        <a
                            href={`mailto:${APP_CONFIG.supportEmail}`}
                            className="px-6 py-3 bg-white text-black font-bold rounded-xl hover:bg-zinc-200 transition-colors inline-block"
                        >
                            Email {APP_CONFIG.supportEmail}
                        </a>
                    </div>
                </div>
            </section>

            {/* FAQ Section */}
            <section>
                <h2 className="text-2xl font-bold mb-8 flex items-center gap-2">
                    <FileQuestion className="text-primary" /> Frequently Asked Questions
                </h2>

                <div className="space-y-6">
                    <FAQItem
                        question="How do I delete my account?"
                        answer="You can initiate account deletion in the app (Home -> Profile (top left corner with picture) -> App & Info -> Delete Account). Your account will be deactivated immediately, and you have 14 days to change your mind. If you don't log back in within 14 days, your data is permanently removed."
                    />
                    <FAQItem
                        question="How do I report inappropriate content?"
                        answer="Tap the three dots (...) on any post or comment and select 'Report'. Our admin team will review the content and take appropriate action against violations of our Terms."
                    />
                    <FAQItem
                        question={`Is ${APP_CONFIG.name} free to use?`}
                        answer={`Yes, ${APP_CONFIG.name} is free for all students to join and use. Some premium features for large event organizers may be introduced in the future.`}
                    />
                    <FAQItem
                        question="Can I create my own community group?"
                        answer="Currently, group creation is restricted to verified student organizers to ensure quality. If you'd like to start a verified group, please contact us for approval."
                    />
                </div>
            </section>
        </div>
    );
}

function FAQItem({ question, answer }: { question: string, answer: string }) {
    return (
        <div className="border border-white/5 bg-zinc-900/30 rounded-xl p-6 hover:border-white/10 transition-colors">
            <h3 className="font-bold text-lg mb-2 text-zinc-200">{question}</h3>
            <p className="text-zinc-400 leading-relaxed">{answer}</p>
        </div>
    );
}
