import "./globals.css";
import { Providers } from "./providers";

export default function RootLayout(props) {
  return (
    <html lang="tr" suppressHydrationWarning>
      <head>
        <link
          href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
          rel="stylesheet"
        />
      </head>
      <body style={{ fontFamily: "'Inter', sans-serif" }}>
        <Providers>
          {props.children}
        </Providers>
      </body>
    </html>
  );
} 