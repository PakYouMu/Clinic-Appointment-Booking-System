require('dotenv').config();

const serviceId = process.env.VITE_EMAILJS_SERVICE_ID;
const templateId = process.env.VITE_EMAILJS_TEMPLATE_ID;
const publicKey = process.env.VITE_EMAILJS_PUBLIC_KEY;

console.log("--- EmailJS Direct Node Test ---");
console.log(`Service ID:  ${serviceId}`);
console.log(`Template ID: ${templateId}`);

if (!serviceId || !templateId || !publicKey || serviceId === "your_emailjs_service_id") {
  console.error("\n❌ ERROR: EmailJS credentials are not set correctly in client/.env");
  process.exit(1);
}

const templateParams = {
  patient_name: "Test Patient",
  doctor_name: "Dr. Test Doctor",
  date: "Monday, Jan 1, 2030",
  time: "10:00 AM",
  to_email: "test.email@example.com" 
};

console.log("\nAttempting to send email via REST API...");

const data = {
  service_id: serviceId,
  template_id: templateId,
  user_id: publicKey,
  template_params: templateParams
};

fetch('https://api.emailjs.com/api/v1.0/email/send', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(data)
})
.then(async (response) => {
  if (response.ok) {
    console.log('✅ SUCCESS! Email sent successfully.');
  } else {
    const text = await response.text();
    console.log(`❌ FAILED with status ${response.status}: ${text}`);
  }
})
.catch((err) => {
  console.log('❌ NETWORK OR FETCH ERROR...', err);
});
