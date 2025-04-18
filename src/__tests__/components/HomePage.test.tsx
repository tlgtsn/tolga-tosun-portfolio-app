import { render, screen } from '@testing-library/react';
import HomePage from '@/app/page';

describe('HomePage', () => {
  it('should render the main heading', () => {
    render(<HomePage />);
    const heading = screen.getByRole('heading', { name: /Tolga Tosun/i });
    expect(heading).toBeInTheDocument();
  });

  it('should render the job title', () => {
    render(<HomePage />);
    const jobTitle = screen.getByText(/Frontend Developer/i);
    expect(jobTitle).toBeInTheDocument();
  });

  it('should render the experience text', () => {
    render(<HomePage />);
    const experience = screen.getByText(/2016'dan beri web geliştirme/i);
    expect(experience).toBeInTheDocument();
  });
}); 