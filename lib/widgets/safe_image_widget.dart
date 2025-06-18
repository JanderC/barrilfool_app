import 'package:flutter/material.dart';

class SafeImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const SafeImage({
    Key? key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si no hay URL, mostrar placeholder por defecto
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildDefaultPlaceholder();
    }

    // Si la URL es de via.placeholder.com, usar placeholder local
    if (imageUrl!.contains('via.placeholder.com')) {
      return _buildDefaultPlaceholder();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? _buildLoadingPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildErrorPlaceholder();
        },
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image,
        size: (width != null && height != null) 
          ? (width! + height!) / 8 
          : 40,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.broken_image,
        size: (width != null && height != null) 
          ? (width! + height!) / 8 
          : 40,
        color: Colors.red[300],
      ),
    );
  }
}

// Widget específico para productos de comida
class FoodImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const FoodImage({
    Key? key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      placeholder: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFF8C00).withOpacity(0.1),
              const Color(0xFFFF8C00).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: (width != null && height != null) 
                ? (width! + height!) / 10 
                : 30,
              color: const Color(0xFFFF8C00).withOpacity(0.6),
            ),
            const SizedBox(height: 4),
            Text(
              'Cargando...',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      errorWidget: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFFF8C00).withOpacity(0.1),
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: (width != null && height != null) 
                ? (width! + height!) / 10 
                : 30,
              color: const Color(0xFFFF8C00),
            ),
            const SizedBox(height: 4),
            Text(
              'Imagen no\ndisponible',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para avatar de usuario
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;

  const UserAvatar({
    Key? key,
    this.imageUrl,
    this.name,
    this.size = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty && !imageUrl!.contains('via.placeholder.com')) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingAvatar();
          },
        ),
      );
    }
    
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFF8C00).withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: const Color(0xFFFF8C00),
      ),
    );
  }

  Widget _buildLoadingAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: SizedBox(
        width: size * 0.4,
        height: size * 0.4,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}