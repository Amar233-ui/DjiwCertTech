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
        document.getElementById('productQrCode').value = '';
        const qrPreview = document.getElementById('qrCodePreview');
        if (qrPreview) {
            qrPreview.style.display = 'none';
        }
        
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
        
        // Traçabilité
        document.getElementById('productOrigin').value = product.origin || '';
        document.getElementById('productCertificationNumber').value = product.certificationNumber || '';
        document.getElementById('productProducerId').value = product.producerId || '';
        document.getElementById('productProducerName').value = product.producerName || '';
        if (product.packagingDate) {
            const packagingDate = product.packagingDate.toDate ? product.packagingDate.toDate() : new Date(product.packagingDate);
            document.getElementById('productPackagingDate').value = packagingDate.toISOString().split('T')[0];
        } else {
            document.getElementById('productPackagingDate').value = '';
        }
        document.getElementById('productPackagingLocation').value = product.packagingLocation || '';
        document.getElementById('productSeason').value = product.season || '';
        document.getElementById('productAgroZone').value = product.agroEcologicalZone || '';
        document.getElementById('productIsForestSeed').checked = product.isForestSeed || false;
        document.getElementById('productQrCode').value = product.qrCode || '';
        
        // Afficher le QR code si existant
        if (product.qrCode) {
            // Attendre un peu pour que le DOM soit prêt
            setTimeout(() => {
                generateQRCodeDisplay(product.qrCode);
            }, 200);
        } else {
            document.getElementById('qrCodePreview').style.display = 'none';
        }
        
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
        
        // Traçabilité
        const origin = document.getElementById('productOrigin').value.trim() || null;
        const certificationNumber = document.getElementById('productCertificationNumber').value.trim() || null;
        const producerId = document.getElementById('productProducerId').value.trim() || null;
        const producerName = document.getElementById('productProducerName').value.trim() || null;
        const packagingDateStr = document.getElementById('productPackagingDate').value;
        const packagingDate = packagingDateStr ? new Date(packagingDateStr) : null;
        const packagingLocation = document.getElementById('productPackagingLocation').value.trim() || null;
        const season = document.getElementById('productSeason').value || null;
        const agroEcologicalZone = document.getElementById('productAgroZone').value || null;
        const isForestSeed = document.getElementById('productIsForestSeed').checked;
        
        // QR Code - générer automatiquement si vide
        let qrCode = document.getElementById('productQrCode').value.trim();
        if (!qrCode) {
            // Générer un QR code unique basé sur le nom, timestamp et un random
            const timestamp = Date.now();
            const random = Math.random().toString(36).substring(2, 9);
            qrCode = `DJIW-${name.toUpperCase().replace(/\s+/g, '-').substring(0, 10)}-${timestamp}-${random}`;
        }
        
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
            // Traçabilité
            origin,
            certificationNumber,
            producerId,
            producerName,
            packagingDate: packagingDate ? firebase.firestore.Timestamp.fromDate(packagingDate) : null,
            packagingLocation,
            season,
            agroEcologicalZone,
            isForestSeed,
            qrCode,
            updatedAt: new Date()
        };
        
        let savedProductId = productId;
        if (productId) {
            // Update existing product
            await window.db.collection(window.COLLECTIONS.products).doc(productId).update(productData);
            alert('Produit modifié avec succès');
        } else {
            // Create new product
            productData.createdAt = new Date();
            const docRef = await window.db.collection(window.COLLECTIONS.products).add(productData);
            savedProductId = docRef.id;
            alert('Produit ajouté avec succès');
        }
        
        // Afficher le QR code généré
        if (qrCode) {
            setTimeout(() => {
                generateQRCodeDisplay(qrCode);
            }, 300);
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
window.generateQRCode = generateQRCode;
window.downloadQRCode = downloadQRCode;
window.printQRCode = printQRCode;

// Fonction pour générer le QR code
function generateQRCode() {
    // Vérifier que la bibliothèque est disponible
    if (typeof QRCode === 'undefined' && typeof window.QRCodeLib === 'undefined') {
        alert('Bibliothèque QRCode non chargée. Veuillez recharger la page (F5).');
        console.error('QRCode non disponible');
        return;
    }
    
    let qrCode = document.getElementById('productQrCode').value.trim();
    if (!qrCode) {
        const name = document.getElementById('productName').value.trim();
        if (!name) {
            alert('Veuillez d\'abord entrer le nom du produit');
            return;
        }
        const timestamp = Date.now();
        const random = Math.random().toString(36).substring(2, 9);
        qrCode = `DJIW-${name.toUpperCase().replace(/\s+/g, '-').substring(0, 10)}-${timestamp}-${random}`;
        document.getElementById('productQrCode').value = qrCode;
    }
    
    if (qrCode) {
        generateQRCodeDisplay(qrCode);
    } else {
        alert('Impossible de générer le QR code. Veuillez entrer un code ou un nom de produit.');
    }
}

// Fonction pour afficher le QR code
function generateQRCodeDisplay(qrCode) {
    if (!qrCode || qrCode.trim() === '') {
        console.warn('QR code vide, impossible de générer');
        return;
    }
    
    const canvas = document.getElementById('qrCodeCanvas');
    if (!canvas) {
        console.error('qrCodeCanvas introuvable');
        return;
    }
    
    canvas.innerHTML = '';
    
    // Vérifier que QRCode est disponible avec plusieurs tentatives
    let qrCodeLib = null;
    if (typeof QRCode !== 'undefined') {
        qrCodeLib = QRCode;
    } else if (typeof window.QRCode !== 'undefined') {
        qrCodeLib = window.QRCode;
    } else if (typeof window.QRCodeLib !== 'undefined') {
        qrCodeLib = window.QRCodeLib;
    } else if (typeof qrcode !== 'undefined') {
        // qrcode-generator library
        qrCodeLib = {
            toCanvas: function(canvas, text, options, callback) {
                try {
                    const typeNumber = 4;
                    const errorCorrectionLevel = 'M';
                    const qr = qrcode(typeNumber, errorCorrectionLevel);
                    qr.addData(text);
                    qr.make();
                    const ctx = canvas.getContext('2d');
                    const moduleCount = qr.getModuleCount();
                    const cellSize = Math.floor(options.width / moduleCount);
                    const size = cellSize * moduleCount;
                    canvas.width = size;
                    canvas.height = size;
                    ctx.fillStyle = options.color.light;
                    ctx.fillRect(0, 0, canvas.width, canvas.height);
                    ctx.fillStyle = options.color.dark;
                    for (let row = 0; row < moduleCount; row++) {
                        for (let col = 0; col < moduleCount; col++) {
                            if (qr.isDark(row, col)) {
                                ctx.fillRect(col * cellSize, row * cellSize, cellSize, cellSize);
                            }
                        }
                    }
                    if (callback) callback(null);
                } catch (e) {
                    if (callback) callback(e);
                }
            }
        };
    }
    
    if (!qrCodeLib) {
        console.error('Bibliothèque QRCode non chargée');
        // Utiliser une API en ligne comme fallback
        const qrApiUrl = `https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${encodeURIComponent(qrCode)}`;
        canvas.innerHTML = `<img src="${qrApiUrl}" alt="QR Code" style="max-width: 250px; height: auto; border: 2px solid #E0E0E0; border-radius: 8px;">`;
        document.getElementById('qrCodePreview').style.display = 'block';
        console.log('✅ QR code généré via API en ligne');
        return;
    }
    
    // Créer un canvas pour le QR code
    const canvasElement = document.createElement('canvas');
    canvas.appendChild(canvasElement);
    
    try {
        qrCodeLib.toCanvas(canvasElement, qrCode, {
            width: 250,
            margin: 2,
            color: {
                dark: '#000000',
                light: '#FFFFFF'
            }
        }, function (error) {
            if (error) {
                console.error('Erreur génération QR code:', error);
                // Fallback vers API en ligne
                const qrApiUrl = `https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${encodeURIComponent(qrCode)}`;
                canvas.innerHTML = `<img src="${qrApiUrl}" alt="QR Code" style="max-width: 250px; height: auto; border: 2px solid #E0E0E0; border-radius: 8px;">`;
                document.getElementById('qrCodePreview').style.display = 'block';
                console.log('✅ QR code généré via API en ligne (fallback)');
            } else {
                document.getElementById('qrCodePreview').style.display = 'block';
                console.log('✅ QR code généré avec succès:', qrCode);
            }
        });
    } catch (e) {
        console.error('Exception lors de la génération QR code:', e);
        // Fallback vers API en ligne
        const qrApiUrl = `https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${encodeURIComponent(qrCode)}`;
        canvas.innerHTML = `<img src="${qrApiUrl}" alt="QR Code" style="max-width: 250px; height: auto; border: 2px solid #E0E0E0; border-radius: 8px;">`;
        document.getElementById('qrCodePreview').style.display = 'block';
        console.log('✅ QR code généré via API en ligne (exception fallback)');
    }
}

// Fonction pour télécharger le QR code
function downloadQRCode() {
    const canvas = document.querySelector('#qrCodeCanvas canvas');
    if (!canvas) {
        alert('Générez d\'abord le QR code en cliquant sur "Générer"');
        return;
    }
    
    const qrCode = document.getElementById('productQrCode').value;
    const productName = document.getElementById('productName').value || 'Produit';
    const fileName = `QR-${productName.replace(/\s+/g, '-')}-${qrCode}.png`;
    
    const link = document.createElement('a');
    link.download = fileName;
    link.href = canvas.toDataURL('image/png');
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    console.log('✅ QR code téléchargé:', fileName);
}

// Fonction pour imprimer le QR code
function printQRCode() {
    const canvas = document.querySelector('#qrCodeCanvas canvas');
    const img = document.querySelector('#qrCodeCanvas img');
    
    if (!canvas && !img) {
        alert('Générez d\'abord le QR code');
        return;
    }
    
    const printWindow = window.open('', '_blank');
    const qrCode = document.getElementById('productQrCode').value;
    const productName = document.getElementById('productName').value || 'Produit';
    
    let qrImageSrc = '';
    if (canvas) {
        qrImageSrc = canvas.toDataURL('image/png');
    } else if (img) {
        qrImageSrc = img.src;
    }
    
    printWindow.document.write(`
        <html>
            <head>
                <title>QR Code - ${productName}</title>
                <style>
                    body {
                        display: flex;
                        flex-direction: column;
                        align-items: center;
                        justify-content: center;
                        height: 100vh;
                        margin: 0;
                        font-family: Arial, sans-serif;
                    }
                    h2 { margin-bottom: 20px; }
                    img { border: 2px solid #000; max-width: 300px; }
                    p { margin-top: 20px; font-size: 14px; }
                </style>
            </head>
            <body>
                <h2>${productName}</h2>
                <img src="${qrImageSrc}" alt="QR Code">
                <p>Code: ${qrCode}</p>
                <p>DjiwCertTech - Traçabilité</p>
            </body>
        </html>
    `);
    printWindow.document.close();
    printWindow.print();
}

console.log('✅ Fonctions de stock exportées:', {
    loadStock: typeof window.loadStock,
    openAddProductModal: typeof window.openAddProductModal,
    editProduct: typeof window.editProduct,
    deleteProduct: typeof window.deleteProduct,
    closeProductModal: typeof window.closeProductModal,
    saveProduct: typeof window.saveProduct,
    generateQRCode: typeof window.generateQRCode,
    downloadQRCode: typeof window.downloadQRCode,
    printQRCode: typeof window.printQRCode
});
