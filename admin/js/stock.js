// Utilise les variables globales depuis config.js
// Pas besoin de déclarer db et COLLECTIONS, ils sont déjà dans window

console.log('📦 Chargement de stock.js...');

let currentEditingProductId = null;

async function loadStock() {
    try {
        if (!window.db || !window.COLLECTIONS) {
            console.error('❌ window.db ou window.COLLECTIONS non disponible');
            return;
        }
        
        const snapshot = await window.db.collection(window.COLLECTIONS.products)
            .orderBy('createdAt', 'desc')
            .get();

        const tbody = document.getElementById('stockTableBody');
        if (!tbody) {
            console.error('❌ stockTableBody introuvable');
            return;
        }
        
        if (snapshot.empty) {
            tbody.innerHTML = '<tr><td colspan="8" style="text-align: center;">Aucun produit trouvé</td></tr>';
            return;
        }

        let html = '';
        snapshot.forEach(doc => {
            const product = doc.data();
            const stockStatus = product.stock > 0 ? 'active' : 'pending';
            const stockClass = product.stock > 10 ? 'success' : product.stock > 0 ? 'warning' : 'error';
            
            html += `
                <tr>
                    <td>
                        <div style="display: flex; align-items: center; gap: 10px;">
                            ${product.imageUrl ? `<img src="${product.imageUrl}" style="width: 40px; height: 40px; object-fit: cover; border-radius: 8px;">` : '<div style="width: 40px; height: 40px; background: #E0E0E0; border-radius: 8px; display: flex; align-items: center; justify-content: center;"><i class="fas fa-image" style="color: #999;"></i></div>'}
                            <span>${product.name || 'N/A'}</span>
                        </div>
                    </td>
                    <td>${product.category || 'N/A'}</td>
                    <td>${product.zone || 'Toutes'}</td>
                    <td>
                        <span class="status-badge status-${stockClass}">${product.stock || 0}</span>
                    </td>
                    <td>
                        ${product.deferredPrice ? `<span style="text-decoration: line-through; color: #999;">${product.price?.toFixed(0) || 0} FCFA</span><br><span style="color: var(--primary-green); font-weight: bold;">${product.deferredPrice.toFixed(0)} FCFA</span>` : `${product.price?.toFixed(0) || 0} FCFA`}
                    </td>
                    <td>${product.certification || '-'}</td>
                    <td>
                        <span class="status-badge status-${product.isAvailable ? 'active' : 'pending'}">
                            ${product.isAvailable ? 'Disponible' : 'Indisponible'}
                        </span>
                    </td>
                    <td>
                        <button class="btn btn-primary" onclick="editProduct('${doc.id}')" style="padding: 6px 12px;">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-danger" onclick="deleteProduct('${doc.id}')" style="padding: 6px 12px;">
                            <i class="fas fa-trash"></i>
                        </button>
                    </td>
                </tr>
            `;
        });

        tbody.innerHTML = html;
    } catch (error) {
        console.error('Error loading stock:', error);
        alert('Erreur lors du chargement des produits');
    }
}

function openAddProductModal() {
    console.log('🔓 Ouverture du modal d\'ajout de produit');
    try {
        currentEditingProductId = null;
        document.getElementById('productModalTitle').textContent = 'Ajouter un produit';
        document.getElementById('productForm').reset();
        document.getElementById('productId').value = '';
        document.getElementById('productImagePreview').style.display = 'none';
        document.getElementById('productImagePreviewImg').src = '';
        document.getElementById('productIsAvailable').checked = true;
        document.getElementById('productRating').value = '0';
        document.getElementById('productReviewCount').value = '0';
        
        // Reset file input
        const fileInput = document.getElementById('productImage');
        if (fileInput) {
            fileInput.value = '';
            
            // Add image preview handler
            fileInput.onchange = function(e) {
                const file = e.target.files[0];
                if (file) {
                    const reader = new FileReader();
                    reader.onload = function(e) {
                        document.getElementById('productImagePreviewImg').src = e.target.result;
                        document.getElementById('productImagePreview').style.display = 'block';
                    };
                    reader.readAsDataURL(file);
                }
            };
        }
        
        const modalOverlay = document.getElementById('productModalOverlay');
        if (modalOverlay) {
            modalOverlay.classList.add('active');
            console.log('✅ Modal d\'ajout de produit ouvert');
        } else {
            console.error('❌ productModalOverlay introuvable');
        }
    } catch (error) {
        console.error('❌ Erreur lors de l\'ouverture du modal:', error);
        alert('Erreur lors de l\'ouverture du formulaire');
    }
}

async function editProduct(productId) {
    try {
        const productDoc = await window.db.collection(window.COLLECTIONS.products).doc(productId).get();
        if (!productDoc.exists) {
            alert('Produit non trouvé');
            return;
        }
        
        const product = productDoc.data();
        currentEditingProductId = productId;
        
        document.getElementById('productModalTitle').textContent = 'Modifier le produit';
        document.getElementById('productId').value = productId;
        document.getElementById('productName').value = product.name || '';
        document.getElementById('productDescription').value = product.description || '';
        document.getElementById('productDetailedDescription').value = product.detailedDescription || '';
        document.getElementById('productCategory').value = product.category || '';
        document.getElementById('productZone').value = product.zone || '';
        document.getElementById('productPrice').value = product.price || 0;
        document.getElementById('productDeferredPrice').value = product.deferredPrice || '';
        document.getElementById('productStock').value = product.stock || 0;
        document.getElementById('productCertification').value = product.certification || '';
        document.getElementById('productRating').value = product.rating || 0;
        document.getElementById('productReviewCount').value = product.reviewCount || 0;
        document.getElementById('productIsAvailable').checked = product.isAvailable !== false;
        
        // Show existing image if available
        if (product.imageUrl) {
            document.getElementById('productImagePreviewImg').src = product.imageUrl;
            document.getElementById('productImagePreview').style.display = 'block';
        } else {
            document.getElementById('productImagePreview').style.display = 'none';
        }
        
        // Reset file input
        document.getElementById('productImage').value = '';
        
        // Add image preview handler
        document.getElementById('productImage').onchange = function(e) {
            const file = e.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    document.getElementById('productImagePreviewImg').src = e.target.result;
                    document.getElementById('productImagePreview').style.display = 'block';
                };
                reader.readAsDataURL(file);
            }
        };
        
        document.getElementById('productModalOverlay').classList.add('active');
    } catch (error) {
        console.error('Error loading product:', error);
        alert('Erreur lors du chargement du produit');
    }
}

function closeProductModal() {
    document.getElementById('productModalOverlay').classList.remove('active');
    currentEditingProductId = null;
}

async function uploadProductImage(file) {
    if (!file) return null;
    
    try {
        // Vérifier que l'utilisateur est authentifié
        const user = window.auth.currentUser;
        if (!user) {
            throw new Error('Vous devez être connecté pour uploader des images');
        }
        
        const storageRef = window.storage.ref();
        const timestamp = Date.now();
        const fileName = `products/${timestamp}_${file.name}`;
        const imageRef = storageRef.child(fileName);
        
        // Upload avec métadonnées pour améliorer la compatibilité
        const metadata = {
            contentType: file.type || 'image/jpeg',
            customMetadata: {
                uploadedBy: user.uid,
                uploadedAt: new Date().toISOString()
            }
        };
        
        const snapshot = await imageRef.put(file, metadata);
        const downloadURL = await snapshot.ref.getDownloadURL();
        
        console.log('✅ Image uploadée avec succès:', downloadURL);
        return downloadURL;
    } catch (error) {
        console.error('❌ Erreur lors de l\'upload de l\'image:', error);
        throw error;
    }
}

async function saveProduct(event) {
    event.preventDefault();
    
    const form = document.getElementById('productForm');
    // Find submit button - check multiple possible locations
    let submitButton = event.submitter;
    if (!submitButton) {
        // Find button in modal footer that triggers submit
        const modalFooter = document.querySelector('#productModal .modal-footer');
        if (modalFooter) {
            submitButton = modalFooter.querySelector('button.btn-primary');
        }
    }
    if (!submitButton) {
        submitButton = form.querySelector('button[type="submit"]');
    }
    
    let originalText = '';
    if (submitButton) {
        originalText = submitButton.innerHTML;
    }
    
    try {
        if (submitButton) {
            submitButton.disabled = true;
            submitButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Enregistrement...';
        }
        
        const productId = document.getElementById('productId').value;
        const name = document.getElementById('productName').value.trim();
        const description = document.getElementById('productDescription').value.trim();
        const detailedDescription = document.getElementById('productDetailedDescription').value.trim();
        const category = document.getElementById('productCategory').value;
        const zone = document.getElementById('productZone').value || null;
        const price = parseFloat(document.getElementById('productPrice').value);
        const deferredPrice = document.getElementById('productDeferredPrice').value ? parseFloat(document.getElementById('productDeferredPrice').value) : null;
        const stock = parseInt(document.getElementById('productStock').value);
        const certification = document.getElementById('productCertification').value.trim() || null;
        const rating = parseFloat(document.getElementById('productRating').value) || 0;
        const reviewCount = parseInt(document.getElementById('productReviewCount').value) || 0;
        const isAvailable = document.getElementById('productIsAvailable').checked;
        const imageFile = document.getElementById('productImage').files[0];
        
        // Upload image if new file selected
        let imageUrl = null;
        if (imageFile) {
            imageUrl = await uploadProductImage(imageFile);
        } else if (productId) {
            // Keep existing image if editing and no new file
            const existingProduct = await window.db.collection(window.COLLECTIONS.products).doc(productId).get();
            if (existingProduct.exists) {
                imageUrl = existingProduct.data().imageUrl || null;
            }
        }
        
        const productData = {
            name,
            description,
            detailedDescription: detailedDescription || null,
            category,
            zone,
            price,
            deferredPrice,
            stock,
            certification,
            rating,
            reviewCount,
            isAvailable,
            imageUrl,
            updatedAt: new Date()
        };
        
        if (productId) {
            // Update existing product
            await window.db.collection(window.COLLECTIONS.products).doc(productId).update(productData);
            alert('Produit modifié avec succès');
        } else {
            // Create new product
            productData.createdAt = new Date();
            await window.db.collection(window.COLLECTIONS.products).add(productData);
            alert('Produit ajouté avec succès');
        }
        
        closeProductModal();
        loadStock();
    } catch (error) {
        console.error('Error saving product:', error);
        alert('Erreur lors de l\'enregistrement: ' + (error.message || 'Erreur inconnue'));
    } finally {
        if (submitButton) {
            submitButton.disabled = false;
            submitButton.innerHTML = originalText;
        }
    }
}

async function deleteProduct(productId) {
    if (!confirm('Êtes-vous sûr de vouloir supprimer ce produit ?')) {
        return;
    }
    
    try {
        await window.db.collection(window.COLLECTIONS.products).doc(productId).delete();
        alert('Produit supprimé avec succès');
        loadStock();
    } catch (error) {
        console.error('Error deleting product:', error);
        alert('Erreur lors de la suppression');
    }
}

// Make functions available globally
console.log('📦 Exportation des fonctions de stock...');
window.loadStock = loadStock;
window.openAddProductModal = openAddProductModal;
window.editProduct = editProduct;
window.deleteProduct = deleteProduct;
window.closeProductModal = closeProductModal;
window.saveProduct = saveProduct;
console.log('✅ Fonctions de stock exportées:', {
    loadStock: typeof window.loadStock,
    openAddProductModal: typeof window.openAddProductModal,
    editProduct: typeof window.editProduct,
    deleteProduct: typeof window.deleteProduct,
    closeProductModal: typeof window.closeProductModal,
    saveProduct: typeof window.saveProduct
});
