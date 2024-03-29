import ReactDOM from 'react-dom/client'
import App from './index.tsx'
import './assets/styles/global.css'
import 'react-toastify/dist/ReactToastify.css';
import { ToastContainer } from 'react-toastify';

ReactDOM.createRoot(document.getElementById('root')!).render(
    <>
        <App />
        <ToastContainer />
    </>
)
