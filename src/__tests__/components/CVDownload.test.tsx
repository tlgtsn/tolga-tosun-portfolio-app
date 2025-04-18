import { render, screen } from '@testing-library/react';
import CVDownload from '@/app/components/CVDownload';

describe('CVDownload', () => {
  it('should render download button', () => {
    render(<CVDownload />);
    const downloadButton = screen.getByRole('button', { name: /cv indir/i });
    expect(downloadButton).toBeInTheDocument();
  });

  it('should have correct download link', () => {
    render(<CVDownload />);
    const downloadLink = screen.getByRole('link');
    expect(downloadLink).toHaveAttribute('href', '/cv.pdf');
    expect(downloadLink).toHaveAttribute('download', 'Tolga_Tosun_CV.pdf');
  });
}); 