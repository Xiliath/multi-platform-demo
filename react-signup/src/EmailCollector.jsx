import React, { useState } from 'react';
import { Mail, QrCode, Users, Download } from 'lucide-react';

export default function EmailCollector() {
  const [emails, setEmails] = useState([]);
  const [currentEmail, setCurrentEmail] = useState('');
  const [showAdmin, setShowAdmin] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  // Get the current URL for the QR code
  const currentUrl = window.location.href;

  const handleSubmit = (e) => {
    e.preventDefault();
    if (currentEmail && currentEmail.includes('@')) {
      setEmails([...emails, { email: currentEmail, timestamp: new Date().toISOString() }]);
      setCurrentEmail('');
      setSubmitted(true);
      setTimeout(() => setSubmitted(false), 3000);
    }
  };

  const downloadEmails = () => {
    const csvContent = 'Email,Timestamp\n' +
      emails.map(e => `${e.email},${e.timestamp}`).join('\n');
    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'speech-trainer-signups.csv';
    a.click();
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      {/* Admin Toggle Button */}
      <button
        onClick={() => setShowAdmin(!showAdmin)}
        className="fixed top-4 right-4 p-3 bg-white rounded-full shadow-lg hover:shadow-xl transition-shadow z-50"
      >
        {showAdmin ? <QrCode className="w-6 h-6 text-indigo-600" /> : <Users className="w-6 h-6 text-indigo-600" />}
      </button>

      {!showAdmin ? (
        /* Registration View */
        <div className="flex items-center justify-center min-h-screen p-4">
          <div className="bg-white rounded-2xl shadow-2xl p-8 max-w-md w-full">
            <div className="text-center mb-6">
              <div className="inline-flex items-center justify-center w-16 h-16 bg-indigo-100 rounded-full mb-4">
                <Mail className="w-8 h-8 text-indigo-600" />
              </div>
              <h1 className="text-3xl font-bold text-gray-800 mb-2">
                AI Speech Trainer
              </h1>
              <p className="text-gray-600">
                Register to test our AI-assisted speech training app
              </p>
            </div>

            {submitted ? (
              <div className="text-center py-8">
                <div className="inline-flex items-center justify-center w-16 h-16 bg-green-100 rounded-full mb-4">
                  <svg className="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                  </svg>
                </div>
                <h2 className="text-2xl font-bold text-gray-800 mb-2">Thank you!</h2>
                <p className="text-gray-600">We'll be in touch soon about testing the app.</p>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
                    Email Address
                  </label>
                  <input
                    type="email"
                    id="email"
                    value={currentEmail}
                    onChange={(e) => setCurrentEmail(e.target.value)}
                    placeholder="your.email@example.com"
                    required
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent outline-none transition"
                  />
                </div>
                <button
                  type="submit"
                  className="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-3 rounded-lg transition-colors shadow-md hover:shadow-lg"
                >
                  Sign Up for Beta Access
                </button>
              </form>
            )}

            <div className="mt-6 pt-6 border-t border-gray-200">
              <p className="text-xs text-center text-gray-500">
                Powered by AI • {emails.length} {emails.length === 1 ? 'person has' : 'people have'} signed up
              </p>
            </div>
          </div>
        </div>
      ) : (
        /* Admin View */
        <div className="container mx-auto px-4 py-8">
          <div className="max-w-4xl mx-auto">
            <div className="bg-white rounded-2xl shadow-2xl p-8">
              <div className="flex items-center justify-between mb-8">
                <div>
                  <h2 className="text-3xl font-bold text-gray-800">Registrations</h2>
                  <p className="text-gray-600 mt-1">Total sign-ups: {emails.length}</p>
                </div>
                {emails.length > 0 && (
                  <button
                    onClick={downloadEmails}
                    className="flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-lg transition-colors"
                  >
                    <Download className="w-4 h-4" />
                    Download CSV
                  </button>
                )}
              </div>

              {emails.length === 0 ? (
                <div className="text-center py-12 text-gray-500">
                  <Users className="w-16 h-16 mx-auto mb-4 opacity-50" />
                  <p className="text-lg">No registrations yet</p>
                  <p className="text-sm mt-2">Share the QR code to start collecting emails</p>
                </div>
              ) : (
                <div className="space-y-3">
                  {emails.map((entry, index) => (
                    <div
                      key={index}
                      className="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
                    >
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 bg-indigo-100 rounded-full flex items-center justify-center">
                          <Mail className="w-4 h-4 text-indigo-600" />
                        </div>
                        <span className="font-medium text-gray-800">{entry.email}</span>
                      </div>
                      <span className="text-sm text-gray-500">
                        {new Date(entry.timestamp).toLocaleString()}
                      </span>
                    </div>
                  ))}
                </div>
              )}

              <div className="mt-8 pt-8 border-t border-gray-200">
                <h3 className="text-lg font-semibold text-gray-800 mb-4">QR Code for Attendees</h3>
                <div className="bg-gray-50 rounded-lg p-6 text-center">
                  <div className="inline-block bg-white p-4 rounded-lg shadow-md">
                    <img
                      src={`https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${encodeURIComponent(currentUrl)}`}
                      alt="QR Code"
                      className="w-64 h-64"
                    />
                  </div>
                  <p className="text-sm text-gray-600 mt-4">
                    Scan this QR code to register for AI Speech Trainer beta access
                  </p>
                  <p className="text-xs text-gray-500 mt-2 font-mono">
                    {currentUrl}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
