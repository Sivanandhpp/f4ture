import { FileText, AlertTriangle, UserX, Gavel, Mail } from 'lucide-react';

export default function Terms() {
    return (
        <div className="max-w-3xl mx-auto py-12">
            <h1 className="text-4xl font-bold mb-2">Terms & Conditions</h1>
            <p className="text-zinc-400 mb-8">Last Updated: January 18, 2026</p>

            <div className="prose prose-invert max-w-none text-zinc-300">
                <p className="lead text-lg text-zinc-400">
                    Please read these Terms and Conditions ("Terms", "Terms and Conditions") carefully before using the Vishayam mobile application (the "Service") operated by us ("us", "we", or "our").
                </p>

                <div className="space-y-12 mt-12">
                    <section>
                        <h2 className="text-2xl font-bold mb-4 text-white flex items-center gap-2">
                            <FileText className="text-primary" /> 1. Agreement to Terms
                        </h2>
                        <p className="text-zinc-400">
                            By accessing or using the Service you agree to be bound by these Terms. If you disagree with any part of the terms then you may not access the Service.
                        </p>
                    </section>

                    <section>
                        <h2 className="text-2xl font-bold mb-4 text-white flex items-center gap-2">
                            <AlertTriangle className="text-primary" /> 2. User Content & Conduct
                        </h2>
                        <p className="text-zinc-400 mb-4">
                            Our Service allows you to post, link, store, share and otherwise make available certain information, text, graphics, videos, or other material ("Content"). You are responsible for the Content that you post to the Service, including its legality, reliability, and appropriateness.
                        </p>
                        <ul className="list-disc pl-6 text-zinc-400 space-y-2">
                            <li>You must not post violent, nude, partially nude, discriminatory, unlawful, infringing, hateful, pornographic or sexually suggestive photos or other content via the Service.</li>
                            <li>You must not defame, stalk, bully, abuse, harass, threaten, impersonate or intimidate people or entities.</li>
                            <li>You may not use the Service for any illegal or unauthorized purpose.</li>
                        </ul>
                    </section>

                    <section>
                        <h2 className="text-2xl font-bold mb-4 text-white flex items-center gap-2">
                            <UserX className="text-primary" /> 3. Termination
                        </h2>
                        <p className="text-zinc-400">
                            We may terminate or suspend access to our Service immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.
                            <br /><br />
                            All provisions of the Terms which by their nature should survive termination shall survive termination, including, without limitation, ownership provisions, warranty disclaimers, indemnity and limitations of liability.
                        </p>
                    </section>

                    <section>
                        <h2 className="text-2xl font-bold mb-4 text-white flex items-center gap-2">
                            <Gavel className="text-primary" /> 4. Limitation of Liability
                        </h2>
                        <p className="text-zinc-400">
                            In no event shall Vishayam, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from (i) your access to or use of or inability to access or use the Service; (ii) any conduct or content of any third party on the Service; (iii) any content obtained from the Service; and (iv) unauthorized access, use or alteration of your transmissions or content, whether based on warranty, contract, tort (including negligence) or any other legal theory.
                        </p>
                    </section>

                    <section>
                        <h2 className="text-2xl font-bold mb-4 text-white">5. Governing Law</h2>
                        <p className="text-zinc-400">
                            These Terms shall be governed and construed in accordance with the laws of India, without regard to its conflict of law provisions.
                        </p>
                    </section>

                    <section>
                        <h2 className="text-2xl font-bold mb-4 text-white">6. Changes</h2>
                        <p className="text-zinc-400">
                            We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material we will try to provide at least 30 days notice prior to any new terms taking effect. What constitutes a material change will be determined at our sole discretion.
                        </p>
                    </section>

                    <section>
                        <h2 className="text-2xl font-bold mb-4 text-white flex items-center gap-2">
                            <Mail className="text-primary" /> 7. Contact Us
                        </h2>
                        <p className="text-zinc-400">
                            If you have any questions about these Terms, please contact us at <a href="mailto:sivanandhpp@gmail.com" className="text-primary hover:underline">sivanandhpp@gmail.com</a>.
                        </p>
                    </section>
                </div>
            </div>
        </div>
    );
}
