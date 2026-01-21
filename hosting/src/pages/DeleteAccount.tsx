import { Trash2, Mail, CheckCircle } from 'lucide-react';
import { APP_CONFIG } from '../config';

export default function DeleteAccount() {
    const handleEmailClick = () => {
        const subject = encodeURIComponent("Delete Account Request");
        const body = encodeURIComponent(
            "I would like to request the deletion of my account.\n\n" +
            "Please delete the account associated with the email address linked to this request.\n" +
            "(Please provide your registered email if different from the sending address)\n\n" +
            "I understand this action is permanent."
        );
        window.location.href = `mailto:${APP_CONFIG.supportEmail}?subject=${subject}&body=${body}`;
    };

    return (
        <div className="max-w-2xl mx-auto py-16 px-4">
            <div className="bg-zinc-900 border border-zinc-800 rounded-2xl p-8 mb-8">
                <div className="w-16 h-16 bg-red-500/10 rounded-full flex items-center justify-center mb-6">
                    <Trash2 className="w-8 h-8 text-red-500" />
                </div>

                <h1 className="text-3xl font-bold mb-4 text-white">Delete Account Request</h1>
                <p className="text-zinc-400 mb-6 text-lg">
                    We're sorry to see you go. If you wish to delete your account and all associated data, you can submit a request directly to our support team.
                </p>

                <div className="space-y-6">
                    <div className="bg-zinc-800/50 rounded-xl p-6">
                        <h3 className="font-semibold text-white mb-2 flex items-center gap-2">
                            <CheckCircle className="w-5 h-5 text-primary" />
                            What happens next?
                        </h3>
                        <ul className="text-zinc-400 space-y-2 list-disc pl-5">
                            <li>Your account will be deactivated immediately upon processing.</li>
                            <li>Your profile and content will be hidden from other users.</li>
                            <li>You have a 14-day grace period to recover your account by logging in.</li>
                            <li>After 14 days, all data is permanently deleted.</li>
                        </ul>
                    </div>
                </div>

                <div className="mt-8">
                    <button
                        onClick={handleEmailClick}
                        className="w-full bg-red-600 hover:bg-red-700 text-white font-semibold py-4 px-6 rounded-xl flex items-center justify-center gap-2 transition-colors"
                    >
                        <Mail className="w-5 h-5" />
                        Send Deletion Request Email
                    </button>
                    <p className="text-center mt-4 text-zinc-500 text-sm">
                        Or email us manually at <span className="text-zinc-300">{APP_CONFIG.supportEmail}</span>
                    </p>
                </div>
            </div>
        </div>
    );
}
