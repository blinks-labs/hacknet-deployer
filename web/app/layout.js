export const metadata = {
  title: 'Hacknet Viz',
  description: 'Latency visualization for mump2p experiments'
};

export default function RootLayout({ children }) {
  return (
    <html lang="en" style={{ height: '100%' }}>
      <body style={{ fontFamily: 'system-ui, -apple-system, Segoe UI, Roboto, sans-serif', margin: 0, height: '100%' }}>
        {children}
      </body>
    </html>
  );
}


