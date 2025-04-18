import { render, screen, fireEvent } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import ContactForm from '@/app/components/ContactForm';

describe('ContactForm', () => {
  it('should show validation errors for empty form submission', async () => {
    render(<ContactForm />);
    const submitButton = screen.getByRole('button', { name: /gönder/i });
    fireEvent.click(submitButton);

    const nameError = await screen.findByText(/İsim alanı zorunludur/i);
    const emailError = await screen.findByText(/Email alanı zorunludur/i);
    const messageError = await screen.findByText(/Mesaj alanı zorunludur/i);

    expect(nameError).toBeInTheDocument();
    expect(emailError).toBeInTheDocument();
    expect(messageError).toBeInTheDocument();
  });

  it('should show email format error for invalid email', async () => {
    render(<ContactForm />);
    const emailInput = screen.getByLabelText(/email/i);
    await userEvent.type(emailInput, 'invalid-email');
    
    const submitButton = screen.getByRole('button', { name: /gönder/i });
    fireEvent.click(submitButton);

    const emailError = await screen.findByText(/Geçerli bir email adresi giriniz/i);
    expect(emailError).toBeInTheDocument();
  });

  it('should submit form successfully with valid data', async () => {
    render(<ContactForm />);
    
    await userEvent.type(screen.getByLabelText(/isim/i), 'Test User');
    await userEvent.type(screen.getByLabelText(/email/i), 'test@example.com');
    await userEvent.type(screen.getByLabelText(/mesaj/i), 'Test message');
    
    const submitButton = screen.getByRole('button', { name: /gönder/i });
    fireEvent.click(submitButton);

    const successMessage = await screen.findByText(/Mesajınız başarıyla gönderildi/i);
    expect(successMessage).toBeInTheDocument();
  });
}); 