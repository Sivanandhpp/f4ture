import { Shield, Lock, Eye, Database, Server, Trash2, Mail } from 'lucide-react';
import { APP_CONFIG } from '../config';

export default function PrivacyPolicy() {
    return (
        <div className="max-w-3xl mx-auto py-12">
            <h1 className="text-4xl font-bold mb-2">Privacy Policy</h1>
            <p className="text-zinc-400 mb-8">Last Updated: January 18, 2026</p>

            <div className="prose prose-invert max-w-none text-zinc-300">
                <p className="lead text-lg text-zinc-400">
                    Your privacy is important to us. This Privacy Policy explains how {APP_CONFIG.name} ("we", "us", or "our") collects, uses, and protects your information when you use our mobile application and related services.
                </p>
                <p className="text-zinc-400 mb-6 font-medium">
                    This Privacy Policy applies to all users of the {APP_CONFIG.name} mobile application on Android and iOS platforms.
                    You can also view this policy within the app at any time by navigating to <strong>Home -&gt; Profile (top left corner with picture) -&gt; App &amp; Info -&gt; Legal</strong>, or on the login screen.
                </p>

                <Section title="1. Information We Collect" icon={<Database className="text-primary" />}>
                    <p>We collect the following types of information to provide and improve our App:</p>
                    <ul className="list-disc pl-6 space-y-2 mt-4 text-zinc-400">
                        <li><strong>Personal Information:</strong> Name, Email address, Phone number, and Profile picture for authentication and profile.</li>
                        <li><strong>Usage Data:</strong> App interactions, crash logs, and performance data.</li>
                        <li><strong>User Content:</strong> Posts, comments, messages, events, and tasks you create or share.</li>
                        <li><strong>Device Information:</strong> Device model, OS version, and unique device identifiers (for push notifications).</li>
                    </ul>
                </Section>

                <Section title="2. How We Use Your Information" icon={<Eye className="text-primary" />}>
                    <ul className="list-disc pl-6 space-y-2 mt-4 text-zinc-400">
                        <li>To provide and maintain the App's core functionalities (account creation, chat, events).</li>
                        <li>To authenticate your identity and secure your account.</li>
                        <li className="font-medium text-white/90">By using the App, you consent to the collection and use of information in accordance with this Privacy Policy.</li>
                        <li>To send you important notifications about your groups, tasks, and events.</li>
                        <li>To monitor usage and fix technical issues.</li>
                    </ul>
                </Section>

                <Section title="3. Mobile App Permissions" icon={<Shield className="text-primary" />}>
                    <p>To provide accurate features, the F4ture mobile application requests the following permissions on your device:</p>
                    <div className="grid gap-4 mt-6">
                        <ServiceCard
                            name="Camera"
                            purpose="To capture photos and videos for your feed posts, stories, and profile picture."
                        />
                        {/* <ServiceCard
                            name="Microphone"
                            purpose="To record audio when capturing videos for posts and stories."
                        /> */}
                        <ServiceCard
                            name="Photo Library & Storage"
                            purpose="To select photos and videos from your gallery for upload and to save content to your device."
                        />
                        {/* <ServiceCard
                            name="Location"
                            purpose="To add location tags to your posts and helping you discover events and communities near you."
                        /> */}
                        <ServiceCard
                            name="Notifications"
                            purpose="To keep you updated on interactions, messages, and important alerts."
                        />
                    </div>
                    <p className="mt-4 text-zinc-400 text-sm">You can manage these permissions anytime in your device settings.</p>
                </Section>

                <Section title="4. Third-Party Services" icon={<Server className="text-primary" />}>
                    <p>We use trusted third-party services to operate our App. These providers have access to your personal information only to perform these tasks on our behalf and are obligated not to disclose or use it for any other purpose.</p>
                    <div className="grid gap-4 mt-6">
                        <ServiceCard
                            name="Firebase Authentication"
                            purpose="To manage user sign-in and account security."
                        />
                        <ServiceCard
                            name="Firebase Cloud Firestore"
                            purpose="To store and sync your app data (profile, posts, messages) securely in the cloud."
                        />
                        <ServiceCard
                            name="Firebase Analytics"
                            purpose="To understand how users interact with the app to improve user experience."
                        />
                        <ServiceCard
                            name="Firebase Cloud Messaging"
                            purpose="To deliver push notifications to your device."
                        />
                    </div>
                    <p className="mt-6 font-medium text-white/90">We do not sell, rent, or trade your personal information to third parties.</p>
                </Section>

                <Section title="5. Data Retention & Deletion" icon={<Trash2 className="text-primary" />}>
                    <p>
                        We retain your personal information only for as long as is necessary for the purposes set out in this Privacy Policy.
                    </p>
                    <p className="mt-4">
                        Users may delete their account directly within the App settings. Upon deletion, all personal data associated with the account will be permanently removed from our active databases, subject to legal retention requirements.
                    </p>
                    <h4 className="text-white font-bold mt-4 mb-2">How to Delete Your Data</h4>
                    <p>
                        You can initiate account deletion directly within the App by navigating to <strong>Home -&gt; Profile (top left corner with picture) -&gt; App &amp; Info -&gt; Delete Account</strong>.
                    </p>
                    <p className="mt-2">
                        Upon request, your account will be <strong>immediately deactivated</strong> and hidden from other users. You will have a <strong>14-day grace period</strong> to reactivate your account by simply logging back in.
                    </p>
                    <p className="mt-2 text-zinc-400">
                        If you do not log in within these 14 days, your account and all associated personal data will be <strong>permanently deleted</strong> from our servers. This permanent deletion is irreversible.
                    </p>
                    <p className="mt-4">
                        You may also request access to, correction of, or assistance with deletion of your personal data by contacting us at <a href={`mailto:${APP_CONFIG.supportEmail}`} className="text-primary hover:underline">{APP_CONFIG.supportEmail}</a>.
                    </p>
                </Section>

                <Section title="6. Security" icon={<Lock className="text-primary" />}>
                    <p>
                        The security of your data is important to us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security.
                        We use industry-standard encryption protocols (such as TLS/SSL) to protect your data during transit.
                    </p>
                </Section>

                <Section title="7. Children's Privacy" icon={<Shield className="text-primary" />}>
                    <p>
                        Our Service does not address anyone under the age of 13. We do not knowingly collect personally identifiable information from anyone under the age of 13.
                    </p>
                </Section>

                <Section title="8. Contact Us" icon={<Mail className="text-primary" />}>
                    <p>If you have any questions about this Privacy Policy, please contact us:</p>
                    <ul className="mt-4">
                        <li>By email: <a href={`mailto:${APP_CONFIG.supportEmail}`} className="text-primary hover:underline">{APP_CONFIG.supportEmail}</a></li>
                    </ul>
                </Section>
            </div>
        </div>
    );
}

function Section({ title, icon, children }: { title: string, icon: any, children: React.ReactNode }) {
    return (
        <div className="mb-12">
            <h2 className="text-2xl font-bold mb-4 flex items-center gap-3 text-white">
                {icon} {title}
            </h2>
            <div className="text-zinc-400 leading-relaxed">
                {children}
            </div>
        </div>
    );
}

function ServiceCard({ name, purpose }: { name: string, purpose: string }) {
    return (
        <div className="bg-zinc-900/40 border border-white/5 p-4 rounded-lg">
            <h4 className="text-white font-bold mb-1">{name}</h4>
            <p className="text-sm text-zinc-400">{purpose}</p>
        </div>
    );
}
