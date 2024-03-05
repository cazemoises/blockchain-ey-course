import { ethers } from 'ethers';
import { useEffect, useState } from 'react';
import teste from "./assets/styles/index.module.css";
import { errorToast, infoToast, successToast } from './components/toasts/Toast';

interface IContract {
	name: string,
	symbol: string, 
	totalSupply: number,
	faceValue: number,
	rating: string,
	issueDate: string,
	maturityPeriod: number
}

function App() {
	
	const [contractInfo, setContractInfo] = useState<IContract>();
	const [recipient, setRecipient] = useState<string>('');
	const [publicKey, setPublicKey] = useState<string>('');
	const [quantity, setQuantity] = useState<number>(0);
	const [balance, setBalance] = useState<number>(-1);

	const CONTRACT_ABI = [{ "inputs": [], "stateMutability": "nonpayable", "type": "constructor" }, { "anonymous": false, "inputs": [{ "indexed": true, "internalType": "address", "name": "owner", "type": "address" }, { "indexed": true, "internalType": "address", "name": "spender", "type": "address" }, { "indexed": false, "internalType": "uint256", "name": "value", "type": "uint256" }], "name": "Approval", "type": "event" }, { "anonymous": false, "inputs": [{ "indexed": true, "internalType": "address", "name": "from", "type": "address" }, { "indexed": true, "internalType": "address", "name": "to", "type": "address" }, { "indexed": false, "internalType": "uint256", "name": "value", "type": "uint256" }], "name": "Transfer", "type": "event" }, { "inputs": [{ "internalType": "address", "name": "tokenOwner", "type": "address" }, { "internalType": "address", "name": "spender", "type": "address" }], "name": "allowance", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" }, { "inputs": [{ "internalType": "address", "name": "spender", "type": "address" }, { "internalType": "uint256", "name": "amount", "type": "uint256" }], "name": "approve", "outputs": [{ "internalType": "bool", "name": "", "type": "bool" }], "stateMutability": "nonpayable", "type": "function" }, { "inputs": [{ "internalType": "address", "name": "tokenOwner", "type": "address" }], "name": "balanceOf", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" }, { "inputs": [{ "internalType": "uint256", "name": "amount", "type": "uint256" }], "name": "burn", "outputs": [], "stateMutability": "nonpayable", "type": "function" }, { "inputs": [{ "internalType": "address", "name": "_newOwner", "type": "address" }], "name": "changeOwner", "outputs": [{ "internalType": "bool", "name": "", "type": "bool" }], "stateMutability": "nonpayable", "type": "function" }, { "inputs": [{ "internalType": "string", "name": "newRating", "type": "string" }], "name": "changeRating", "outputs": [], "stateMutability": "nonpayable", "type": "function" }, { "inputs": [], "name": "decimals", "outputs": [{ "internalType": "uint8", "name": "", "type": "uint8" }], "stateMutability": "view", "type": "function" }, { "inputs": [], "name": "faceValue", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" }, { "inputs": [], "name": "issueDate", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" }, { "inputs": [], "name": "maturityPeriod", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" }, { "inputs": [{ "internalType": "uint256", "name": "amount", "type": "uint256" }], "name": "mint", "outputs": [], "stateMutability": "nonpayable", "type": "function" }, { "inputs": [], "name": "name", "outputs": [{ "internalType": "string", "name": "", "type": "string" }], "stateMutability": "view", "type": "function" }, { "inputs": [], "name": "rating", "outputs": [{ "internalType": "string", "name": "", "type": "string" }], "stateMutability": "view", "type": "function" }, { "inputs": [], "name": "symbol", "outputs": [{ "internalType": "string", "name": "", "type": "string" }], "stateMutability": "view", "type": "function" }, { "inputs": [], "name": "totalSupply", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" }, { "inputs": [{ "internalType": "address", "name": "to", "type": "address" }, { "internalType": "uint256", "name": "amount", "type": "uint256" }], "name": "transfer", "outputs": [{ "internalType": "bool", "name": "", "type": "bool" }], "stateMutability": "nonpayable", "type": "function" }, { "inputs": [{ "internalType": "address", "name": "from", "type": "address" }, { "internalType": "address", "name": "to", "type": "address" }, { "internalType": "uint256", "name": "amount", "type": "uint256" }], "name": "transferFrom", "outputs": [{ "internalType": "bool", "name": "", "type": "bool" }], "stateMutability": "nonpayable", "type": "function" }, { "inputs": [], "name": "whoIsTheOwner", "outputs": [{ "internalType": "address", "name": "", "type": "address" }], "stateMutability": "view", "type": "function" }];

	const CONTRACT_ADDRESS = "0x76311e6Ec0cDa7E1a49862eF7a63ed4d408aDb81";

	async function getProviderOrSigner(needSigner = false) {
		if (!window.ethereum) {
			errorToast("Nenhum provider encontrado.")
			throw new Error("Nenhum provider encontrado.");
		}

		await window.ethereum.request({ method: 'eth_requestAccounts' });

		const provider = new ethers.BrowserProvider(window.ethereum);

		return needSigner ? provider.getSigner() : provider;
	}

	function timestampToMonths(timestamp: bigint) {
		const SECONDS_IN_A_MONTH = 2629746n;
		const SECONDS_IN_A_DAY = 86400n;
		if (timestamp < SECONDS_IN_A_MONTH) {
			return [timestamp / SECONDS_IN_A_DAY];
		}
		return timestamp / SECONDS_IN_A_MONTH;
	}

	async function getBalanceOf(address: string) {
		const provider = await getProviderOrSigner();
		const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, provider);
		try {
			console.log("teste")
			const balance = await contract.balanceOf(address);
			setBalance(Number(balance));
			console.log(balance);
			successToast(`Saldo obtido com sucesso! (${balance} tokens).`);
		} catch (error) {
			errorToast("Erro ao obter saldo, verifique o console.");
		}
	}

	async function transferTokens(to: string, amount: ethers.BigNumberish) {
		try {
			const signer = await getProviderOrSigner(true);
			const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer);
	
			const transaction = await contract.transfer(to, amount);
			infoToast("Transação enviada, aguarde a confirmação.")
			await transaction.wait();
			successToast(`${amount} tokens enviados para ${to} com sucesso!`);
		} catch(error) {
			errorToast("Erro ao transferir tokens, verifique o console.");
		}
	}

	function convertBigIntToDate(bigInt: ethers.BigNumberish) {
		const timestampNumber = Number(bigInt);
		console.log(timestampNumber)
		const date = new Date(timestampNumber * 1000);
		console.log(date)
		return date.toISOString().split("T")[0];
	}

	async function getContractInfo() {
		const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, await getProviderOrSigner());
		console.log(await getProviderOrSigner())
		const contractData = {
			name: await contract.name(),
			symbol: await contract.symbol(),
			totalSupply: Number(await contract.totalSupply()),
			faceValue: Number(await contract.faceValue()),
			rating: await contract.rating(),
			issueDate: convertBigIntToDate(await contract.issueDate()),
			maturityPeriod: Number(timestampToMonths(await contract.maturityPeriod()))
		};
		return setContractInfo(contractData);
	}

	useEffect(() => {

		getContractInfo();

	}, [])
	
	// -- Interação do Usuário --
	// Saldo de Tokens
	// Transferir Tokens
	
	
	// -- Informações do Contrato --
	// Nome e Símbolo do Token
	// Total de Tokens Emitidos
	// Valor Nominal (faceValue)
	// Classificação de Risco (Rating)
	// Data de Emissão
	// Período de Maturidade

	return (
		<div className={teste.container}>
			<div>
				<h1>Token {contractInfo?.name}</h1>
				<h2>({contractInfo?.symbol})</h2>
			</div>
			<div className={teste.debentureInfo}>
				<div>
					<p>Token</p>
					{contractInfo?.name || "Carregando dados..."}
				</div>
				<div>
					<p>Símbolo</p>
					<span>
						{contractInfo?.symbol || "Carregando dados..."}
					</span>
				</div>
				<div>
					<p>Total Emitido</p>
					<span>
						{contractInfo?.totalSupply || "Carregando dados..."}
					</span>
				</div>
				<div>
					<p>Valor Nominal</p>
					<span>
						{contractInfo?.faceValue || "Carregando dados..."}
					</span>
				</div>
				<div>
					<p>Classificação de Risco</p>
					<span>
						{contractInfo?.rating || "Carregando dados..."}
					</span>
				</div>
				<div>
					<p>Data de emissão</p>
					<span>{contractInfo?.issueDate || "Carregando dados..."}</span>
				</div>
				<div>
					<p>Período de Maturidade</p>
					<span>{contractInfo?.maturityPeriod + " meses" || "Carregando dados..."}</span>
				</div>
			</div>
			<div className={teste.interactions}>
				<div>
					<span>Consultar saldo</span>
					<input
						placeholder='Sua chave pública'
						type='text'
						id='publicKey'
						value={publicKey}
						onChange={(e) => setPublicKey(e.target.value)}
					/>
					<p className={teste.value}>
						{balance >= 0 ? `O seu saldo é: ${balance}` : ""}
					</p>
					<button
						className={teste.balanceButton}
						onClick={() => {getBalanceOf(publicKey)}}>Confirmar</button>
				</div>
				<div>
					<span>Transferir Tokens</span>
					<input
						placeholder='Destinatário'
						type='text'
						id='recipient'
						value={recipient}
						onChange={(e) => setRecipient(e.target.value)}
					/>
					<input
						placeholder='Quantidade'
						type='number'
						id='quantity'
						value={quantity}
						onChange={(e) => setQuantity(Number(e.target.value))}
					/>
					<button
						onClick={() => {transferTokens(recipient, quantity as number)}}
					>
						Confirmar
					</button>
				</div>
			</div>
		</div>
	)
}

export default App;