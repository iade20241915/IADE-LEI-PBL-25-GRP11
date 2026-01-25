import 'package:flutter/material.dart';

/// Banner animado que mostra o status de gravação
class SaveStatusBanner extends StatelessWidget {
  final bool isVisible;
  final bool isSaving;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;

  const SaveStatusBanner({
    super.key,
    this.isVisible = false,
    this.isSaving = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isVisible ? 48 : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isVisible ? 1.0 : 0.0,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(),
              const SizedBox(width: 10),
              Text(
                _getMessage(),
                style: TextStyle(
                  color: _getTextColor(),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isSaving) return Colors.blue.shade50;
    if (isSuccess) return Colors.green.shade50;
    if (isError) return Colors.red.shade50;
    return Colors.grey.shade100;
  }

  Color _getTextColor() {
    if (isSaving) return Colors.blue.shade700;
    if (isSuccess) return Colors.green.shade700;
    if (isError) return Colors.red.shade700;
    return Colors.grey.shade700;
  }

  Widget _buildIcon() {
    if (isSaving) {
      return SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.blue.shade700,
        ),
      );
    }
    if (isSuccess) {
      return Icon(Icons.check_circle, color: Colors.green.shade700, size: 20);
    }
    if (isError) {
      return Icon(Icons.error_outline, color: Colors.red.shade700, size: 20);
    }
    return const SizedBox.shrink();
  }

  String _getMessage() {
    if (isSaving) return 'A guardar...';
    if (isSuccess) return 'Guardado com sucesso!';
    if (isError) return errorMessage ?? 'Erro ao guardar';
    return '';
  }
}

/// Versão compacta para usar em cards
class SaveStatusIndicator extends StatelessWidget {
  final bool isSaving;
  final bool isSuccess;

  const SaveStatusIndicator({
    super.key,
    this.isSaving = false,
    this.isSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSaving && !isSuccess) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSaving ? Colors.blue.shade100 : Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSaving)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue.shade700,
              ),
            )
          else
            Icon(Icons.check, color: Colors.green.shade700, size: 14),
          const SizedBox(width: 4),
          Text(
            isSaving ? 'A guardar...' : 'Guardado!',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSaving ? Colors.blue.shade700 : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
