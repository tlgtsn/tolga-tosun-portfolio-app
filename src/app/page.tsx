import Image from "next/image";

export default function HomePage() {
  return (
    <main className="min-h-screen p-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold mb-4">Tolga Tosun</h1>
        <h2 className="text-2xl text-gray-600 dark:text-gray-300 mb-4">Frontend Developer</h2>
        <p className="text-lg mb-8">2016'dan beri web geliştirme alanında çalışmaktayım.</p>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          <section>
            <h3 className="text-xl font-semibold mb-4">Hakkımda</h3>
            <p className="text-gray-700 dark:text-gray-300">
              Modern web teknolojileri ile kullanıcı dostu ve performanslı uygulamalar geliştiriyorum.
              React, Next.js ve TypeScript konularında uzmanlaşmış durumdayım.
            </p>
          </section>
          
          <section>
            <h3 className="text-xl font-semibold mb-4">İletişim</h3>
            <p className="text-gray-700 dark:text-gray-300">
              Projeleriniz için benimle iletişime geçebilirsiniz.
            </p>
          </section>
        </div>
      </div>
    </main>
  );
}
