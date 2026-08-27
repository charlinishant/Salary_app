import { employeeCrudRouter } from './genericEmployeeRoutes.js';
export default employeeCrudRouter('expense', { include: { attachments: true } });
