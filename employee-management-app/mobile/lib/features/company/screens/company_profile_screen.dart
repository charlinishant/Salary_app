import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/company_provider.dart';
import 'edit_company_screen.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CompanyProvider>().loadCompany();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompanyProvider>();
    final company = provider.company;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5ECE2),
        elevation: 0,
        title: const Text(
          'Company Profile',
          style: TextStyle(color: Color(0xFF1B241A), fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (company != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF1B241A)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditCompanyScreen(company: company)),
                );
              },
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(provider.error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => provider.loadCompany(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : company == null
                  ? const Center(child: Text('No company profile found'))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Header Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E9DE)),
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: const Color(0xFFE5ECE2),
                                child: Text(
                                  company.name.isNotEmpty ? company.name[0].toUpperCase() : 'C',
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                company.name,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B241A)),
                                textAlign: TextAlign.center,
                              ),
                              if (company.legalName != null && company.legalName!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  company.legalName!,
                                  style: const TextStyle(fontSize: 14, color: AppColors.muted),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Code: ${company.companyCode}',
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // General Details
                        _buildSectionCard('General Information', [
                          _buildDetailRow('Industry', company.industry ?? 'N/A'),
                          _buildDetailRow('Email', company.email ?? 'N/A'),
                          _buildDetailRow('Phone', company.phone ?? 'N/A'),
                          _buildDetailRow('Website', company.website ?? 'N/A'),
                          _buildDetailRow('Address', '${company.address ?? ''}, ${company.city ?? ''}, ${company.state ?? ''} ${company.postalCode ?? ''}'),
                        ]),

                        const SizedBox(height: 16),

                        // Tax & Registration Details
                        _buildSectionCard('Tax & Registrations', [
                          _buildDetailRow('GSTIN', company.gstin ?? 'N/A'),
                          _buildDetailRow('PAN', company.pan ?? 'N/A'),
                          _buildDetailRow('TAN', company.tan ?? 'N/A'),
                          _buildDetailRow('PF Reg No', company.pfNumber ?? 'N/A'),
                          _buildDetailRow('ESI Reg No', company.esiNumber ?? 'N/A'),
                          _buildDetailRow('PT Reg No', company.ptNumber ?? 'N/A'),
                        ]),

                        const SizedBox(height: 16),

                        // Payroll Settings
                        _buildSectionCard('Payroll & Time Settings', [
                          _buildDetailRow('Payroll Currency', company.currency),
                          _buildDetailRow('Time Zone', company.timezone),
                          _buildDetailRow('Week Start Day', company.weekStartDay),
                        ]),
                      ],
                    ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E9DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1B241A)),
          ),
          const Divider(height: 20, color: Color(0xFFE2E9DE)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 14)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFF1B241A)),
            ),
          ),
        ],
      ),
    );
  }
}
